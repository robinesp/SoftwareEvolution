module SuggestionGenerator

import IO;
import String;
import List;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;
import FlowGraphsAndClassDiagrams;
import Util;

rel[loc, loc] getSingleSuggestions (set[loc] collections, OFG ofg, M3 m) {
	single_suggestions = {};
	for(col <- collections) {
		assigned_objects = { from | <from, to> <- ofg, to==col, contains(from.scheme, "variable") || contains(from.scheme, "field") || contains(from.scheme, "parameter") };
			
		assigned_types = {};
		for(obj <- assigned_objects) {
			prev = [];
			do {
				prev = [ from | <from, to> <- ofg, to==obj, !contains(from.scheme, "interface") && !contains(from.scheme, "id") ];
				if(size(prev)>0 && !contains(obj.scheme, "class")) obj = prev[0];
			} while (size(prev)>0 && !contains(obj.scheme, "class"));
			
			if(contains(obj.scheme, "class"))
				assigned_types += obj;
		}
		
		if (size(assigned_types)==0)
			continue;
		else 
			suggested_type = (size(assigned_types)==1) ?getOneFrom(assigned_types) : getSmallestCommonSuperclass(assigned_types, m);
			
		single_suggestions += <col, suggested_type>;
	}
	return single_suggestions;
}


void doSingleCorrections (rel[loc,loc] single_suggestions, loc project_new, M3 m) {

	for(<variable, class> <- single_suggestions) {
		location = [ file | <var, file> <- m.declarations, var==variable ][0];
		location.length = 1000;
		location.offset -= location.begin.column;
		old_line = readFileLines(location)[0];
		
		className = split("/", class.path)[size(split("/", class.path))-2];
		splitted = split(" ", old_line);
		str new_line = "";
		for(i <- [0..size(splitted)]) {
			if(i==0) new_line += splitted[i] + "\<" + className + "\> ";
			else if (i==4 && splitted[i-1]=="new")  new_line += split("()",splitted[i])[0] + "\<\>();";
			else new_line += splitted[i] + " ";
		}
		
		//print suggestion to file
		appendToFile(|project://Assignment2/suggestions.txt|,"@");
		appendToFile(|project://Assignment2/suggestions.txt|,location);
		appendToFile(|project://Assignment2/suggestions.txt|,"\n"+old_line+"\n");
		appendToFile(|project://Assignment2/suggestions.txt|,new_line+"\n\n");
		
		//change line in file
		file_path = |<project_new.scheme>://<project_new.authority><location.path>|;
		file_content = readFile(file_path);
		whole_file = contains(file_content, "\r\n") ? split("\r\n",file_content) : split("\n",file_content);
		line_index = location.begin.line;
		whole_file[line_index-1] = new_line;		
		writeFile(file_path,"");
		for(line <- whole_file)
			appendToFile(file_path, line+"\r\n");
	}
}

void doSingleMethodCorrections (rel[loc,loc] single_suggestions, loc project_new, OFG ofg, M3 m) {
	
	for(<variable, class> <- single_suggestions) {
		return_methods = [ to | <from, to> <- ofg, from==variable, contains(to.path, "return") ];
		if(size(return_methods)>0) {		
			methodName = |<return_methods[0].scheme>://<return_methods[0].authority><return_methods[0].path[..size(return_methods[0].path)-7]>|;			
			location = [ file | <var, file> <- m.declarations, var==methodName ][0];
			location.length = 1000;
			location.offset -= location.begin.column;
			old_line = readFileLines(location)[0];
			
			className = split("/", class.path)[size(split("/", class.path))-2];
			splitted = split(" ", old_line);
			str new_line = "";
			for(i <- [0..size(splitted)]) {
				if(i==2) new_line += splitted[i] + "\<" + className + "\> ";
				else new_line += splitted[i] + " ";
			}
			
			//print suggestion to file
			appendToFile(|project://Assignment2/suggestions.txt|,"@");
			appendToFile(|project://Assignment2/suggestions.txt|,location);
			appendToFile(|project://Assignment2/suggestions.txt|,"\n"+old_line+"\n");
			appendToFile(|project://Assignment2/suggestions.txt|,new_line+"\n\n");
			
			//change line in file
			file_path = |<project_new.scheme>://<project_new.authority><location.path>|;
			file_content = readFile(file_path);
			whole_file = contains(file_content, "\r\n") ? split("\r\n",file_content) : split("\n",file_content);
			line_index = location.begin.line;
			whole_file[line_index-1] = new_line;		
			writeFile(file_path,"");
			for(line <- whole_file)
				appendToFile(file_path, line+"\r\n");
		}
	}
}

rel[loc, loc, loc] getDoubleSuggestions (set[loc] collections, OFG ofg, M3 m) {
	single_suggestions = {};
	for(col <- collections) {
		assigned_objects = { from | <from, to> <- ofg, to==col, contains(from.scheme, "variable") || contains(from.scheme, "field") || contains(from.scheme, "parameter") };
			
		assigned_types = {};
		for(obj <- assigned_objects) {
			prev = [];
			do {
				prev = [ from | <from, to> <- ofg, to==obj, !contains(from.scheme, "interface") && !contains(from.scheme, "id") ];
				if(size(prev)>0 && !contains(obj.scheme, "class")) obj = prev[0];
			} while (size(prev)>0 && !contains(obj.scheme, "class"));
			
			if(contains(obj.scheme, "class"))
				assigned_types += obj;
		}
		
		if (size(assigned_types)==0)
			continue;
		else 
			suggested_type = (size(assigned_types)==1) ?getOneFrom(assigned_types) : getSmallestCommonSuperclass(assigned_types, m);
			
		key_types = getKeyTypes(col, m);
		key_type = (size(key_types)==1) ? getOneFrom(key_types) : getSmallestCommonSuperclass(key_types, m);
		single_suggestions += <col, key_type, suggested_type>;
	}
	return single_suggestions;
}


void doDoubleCorrections (rel[loc,loc,loc] double_suggestions, loc project_new, M3 m) {

	for(<variable, class1, class2> <- double_suggestions) {
		location = [ file | <var, file> <- m.declarations, var==variable ][0];
		location.length = 1000;
		location.offset -= location.begin.column;
		old_line = readFileLines(location)[0];
		
		className1 = split("/", class1.path)[size(split("/", class1.path))-2];
		className2 = split("/", class2.path)[size(split("/", class2.path))-2];
		splitted = split(" ", old_line);
		str new_line = "";
		for(i <- [0..size(splitted)]) {
			if(i==0) new_line += splitted[i] + "\<" + className1 + ", " + className2 + "\> ";
			else if (i==4 && splitted[i-1]=="new")  new_line += split("()",splitted[i])[0] + "\<\>();";
			else new_line += splitted[i] + " ";
		}
		
		//print suggestion to file
		appendToFile(|project://Assignment2/suggestions.txt|,"@");
		appendToFile(|project://Assignment2/suggestions.txt|,location);
		appendToFile(|project://Assignment2/suggestions.txt|,"\n"+old_line+"\n");
		appendToFile(|project://Assignment2/suggestions.txt|,new_line+"\n\n");
		
		//change line in file
		file_path = |<project_new.scheme>://<project_new.authority><location.path>|;
		file_content = readFile(file_path);
		whole_file = contains(file_content, "\r\n") ? split("\r\n",file_content) : split("\n",file_content);
		line_index = location.begin.line;
		whole_file[line_index-1] = new_line;		
		writeFile(file_path,"");
		for(line <- whole_file)
			appendToFile(file_path, line+"\r\n");
	}
}

void doDoubleMethodCorrections (rel[loc,loc,loc] single_suggestions, loc project_new, OFG ofg, M3 m) {
	
	for(<variable, class1, class2> <- single_suggestions) {
		return_methods = [ to | <from, to> <- ofg, from==variable, contains(to.path, "return") ];
		if(size(return_methods)>0) {		
			methodName = |<return_methods[0].scheme>://<return_methods[0].authority><return_methods[0].path[..size(return_methods[0].path)-7]>|;			
			location = [ file | <var, file> <- m.declarations, var==methodName ][0];
			location.length = 1000;
			location.offset -= location.begin.column;
			old_line = readFileLines(location)[0];
			
			//check that method requires two types
			if (!contains(old_line,"Map")) continue;
						
			className1 = split("/", class1.path)[size(split("/", class1.path))-2];
			className2 = split("/", class2.path)[size(split("/", class2.path))-2];
			splitted = split(" ", old_line);
			str new_line = "";
			for(i <- [0..size(splitted)]) {
				if(i==2) new_line += splitted[i] + "\<" + className1 + "," + className2 + "\> ";
				else new_line += splitted[i] + " ";
			}
			
			//print suggestion to file
			appendToFile(|project://Assignment2/suggestions.txt|,"@");
			appendToFile(|project://Assignment2/suggestions.txt|,location);
			appendToFile(|project://Assignment2/suggestions.txt|,"\n"+old_line+"\n");
			appendToFile(|project://Assignment2/suggestions.txt|,new_line+"\n\n");
			
			//change line in file
			file_path = |<project_new.scheme>://<project_new.authority><location.path>|;
			file_content = readFile(file_path);
			whole_file = contains(file_content, "\r\n") ? split("\r\n",file_content) : split("\n",file_content);
			line_index = location.begin.line;
			whole_file[line_index-1] = new_line;		
			writeFile(file_path,"");
			for(line <- whole_file)
				appendToFile(file_path, line+"\r\n");
		}
	}
}