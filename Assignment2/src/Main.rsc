module Main

import IO;
import String;
import List;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;
import FlowGraphsAndClassDiagrams;


void generate_suggestions(loc project) {

	//create m3 model
	m = createM3FromEclipseProject(project);
	//show diagram
	//drawDiagram(m);
	//print diagram to file
	//showDot(m);
	
	//create flow program
	set[Declaration] asts = createAstsFromFiles(toSet(project.ls), true);
	p = createOFG(asts);
	
	//print statements to file
	writeFile(|project://Assignment2/statements.txt|,"");
	for(x <- p.statements) {
		appendToFile(|project://Assignment2/statements.txt|,x);
		appendToFile(|project://Assignment2/statements.txt|,"\n");
	}
	
	//print decls to file
	writeFile(|project://Assignment2/decls.txt|,"");
	for(x <- p.decls) {
		appendToFile(|project://Assignment2/decls.txt|,x);
		appendToFile(|project://Assignment2/decls.txt|,"\n");
	}
	
	//build OFG graph
	OFG ofg = buildGraph(p, m);
	writeFile(|project://Assignment2/links.txt|,"");
	for(x <- ofg) {
		appendToFile(|project://Assignment2/links.txt|,x);
		appendToFile(|project://Assignment2/links.txt|,"\n");
	}
	

	//create copy of the project
	loc project_new = |<project.scheme>://<project.authority><project.path[..size(project.path)-1]+"_modernized">|;
	mkDirectory(project_new);
	for(file <- toSet(project.ls), contains(file.path, "java")) {
		writeFile(|<project_new.scheme>://<project_new.authority><file.path>|, readFile(file));
	}
	
	//create suggestions output files
	writeFile(|project://Assignment2/suggestions.txt|,"");
	
	
	//get collections with single type
	toCorrect_single = {};
	for(interface <- ["List", "Iterator", "Collection", "Comparator", "Deque", "Enumeration", "ListIterator", "NavigableSet", "Queue", "Set", "SortedSet"])
		toCorrect_single += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	//generate single type suggestion
	//TODO: these two variables are not linked to any suggestion:
	//|java+variable:///Main/searchDoc(java.lang.String)/docs| and |java+variable:///Main/searchUser(java.lang.String)/users|
	single_suggestions = getSingleSuggestions(ofg, toCorrect_single);
	doSingleCorrections(single_suggestions, project_new, m);
	doSingleMethodCorrections(single_suggestions, project_new, ofg, m);
	
	
	//get collections with double type
	toCorrect_double = {};
	for(interface <- ["Map", "Map.Entry", "NavigableMap", "SortedMap"])
		toCorrect_double += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	//generate double type suggestion
	double_suggestions = getDoubleSuggestions(ofg, toCorrect_double);
	doDoubleCorrections(double_suggestions, project_new, m);
	doDoubleMethodCorrections(double_suggestions, project_new, ofg, m);
}


rel[loc, loc] getSingleSuggestions (OFG ofg, set[loc] collections) {
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
		
		loc suggested_type;
		if (size(assigned_types)==0)
			//skip suggestion
			continue;
		else if (size(assigned_types)==1)
			//only one type to suggest
			suggested_type = getOneFrom(assigned_types);
		else
			//TODO: find smallest common subtype
			continue;
			
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
		
		className = split("/", class.path)[1];
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
		whole_file = split("\r\n",readFile(file_path));
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
			
			className = split("/", class.path)[1];
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
			whole_file = split("\r\n",readFile(file_path));
			line_index = location.begin.line;
			whole_file[line_index-1] = new_line;		
			writeFile(file_path,"");
			for(line <- whole_file)
				appendToFile(file_path, line+"\r\n");
		}
	}
}

rel[loc, loc, loc] getDoubleSuggestions (OFG ofg, set[loc] collections) {
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
		
		loc suggested_type;
		if (size(assigned_types)==0)
			//skip suggestion
			continue;
		else if (size(assigned_types)==1)
			//only one type to suggest
			suggested_type = getOneFrom(assigned_types);
		else
			//TODO: find smallest common subtype
			continue;
			
		//TODO: find actual key type
		single_suggestions += <col, suggested_type, suggested_type>;
	}
	return single_suggestions;
}


void doDoubleCorrections (rel[loc,loc,loc] double_suggestions, loc project_new, M3 m) {

	for(<variable, class1, class2> <- double_suggestions) {
		location = [ file | <var, file> <- m.declarations, var==variable ][0];
		location.length = 1000;
		location.offset -= location.begin.column;
		old_line = readFileLines(location)[0];
		
		className1 = split("/", class1.path)[1];
		className2 = split("/", class2.path)[1];
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
		whole_file = split("\r\n",readFile(file_path));
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
						
			className1 = split("/", class1.path)[1];
			className2 = split("/", class2.path)[1];
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
			whole_file = split("\r\n",readFile(file_path));
			line_index = location.begin.line;
			whole_file[line_index-1] = new_line;		
			writeFile(file_path,"");
			for(line <- whole_file)
				appendToFile(file_path, line+"\r\n");
		}
	}
}

void run() {
	generate_suggestions(|project://eLib/|);
}