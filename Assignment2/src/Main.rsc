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
	
	
	//get collections with single type
	toCorrect_single = {};
	for(interface <- ["List", "Iterator", "Collection", "Comparator", "Deque", "Enumeration", "ListIterator", "NavigableSet", "Queue", "Set", "SortedSet"])
		toCorrect_single += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	//get collections with double type
	toCorrect_double = {};
	for(interface <- ["Map", "Map.Entry", "NavigableMap", "SortedMap"])
		toCorrect_double += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	
	//get single type suggestion
	single_suggestions = getSingleSuggestions(ofg, toCorrect_single);
	
	//print <collection, suggested type>
	for(x <- single_suggestions)
		println(x);
	
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
				if(size(prev)>0) obj = prev[0];
			} while (size(prev)>0 && !contains(obj.scheme, "class"));
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


void run() {
	generate_suggestions(|project://eLib/|);
}