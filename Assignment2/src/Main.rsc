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
import SuggestionGenerator;
import Util;

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
	
	/*//print statements to file
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
	}*/
	
	//build OFG graph
	OFG ofg = buildGraph(p, m);
	/*writeFile(|project://Assignment2/links.txt|,"");
	for(x <- ofg) {
		appendToFile(|project://Assignment2/links.txt|,x);
		appendToFile(|project://Assignment2/links.txt|,"\n");
	}*/
	

	//create copy of the project
	loc project_new = |<project.scheme>://<project.authority><project.path[..size(project.path)-1]+"_modernized">|;
	mkDirectory(project_new);
	for(file <- toSet(project.ls), contains(file.path, ".java")) {
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
	single_suggestions = getSingleSuggestions(toCorrect_single, ofg, m);
	doSingleCorrections(single_suggestions, project_new, m);
	doSingleMethodCorrections(single_suggestions, project_new, ofg, m);
	
	
	//get collections with double type
	toCorrect_double = {};
	for(interface <- ["Map", "Map.Entry", "NavigableMap", "SortedMap"])
		toCorrect_double += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	//generate double type suggestion
	double_suggestions = getDoubleSuggestions(toCorrect_double, ofg, m);
	doDoubleCorrections(double_suggestions, project_new, m);
	doDoubleMethodCorrections(double_suggestions, project_new, ofg, m);
}


void run() {
	generate_suggestions(|project://eLib/|);
}