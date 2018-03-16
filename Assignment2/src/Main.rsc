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

	//create m3 model, flow program and OFG graph
	m = createM3FromEclipseProject(project);
	set[Declaration] asts = createAstsFromFiles(toSet(project.ls), true);
	p = createOFG(asts);
	OFG ofg = buildGraph(p, m);


	//create copy of the project
	loc project_new = |<project.scheme>://<project.authority><project.path[..size(project.path)-1]+"_modernized">|;
	mkDirectory(project_new);
	for(file <- toSet(project.ls), contains(file.path, ".java")) {
		writeFile(|<project_new.scheme>://<project_new.authority><file.path>|, readFile(file));
	}
	
	//create suggestions output file
	writeFile(|project://Assignment2/suggestions.txt|,"");
	
	
	//get collections with single type
	toCorrect_single = {};
	for(interface <- ["List", "Iterator", "Collection", "Comparator", "Deque", "Enumeration", "ListIterator", "NavigableSet", "Queue", "Set", "SortedSet"])
		toCorrect_single += { to | <to, from> <- m.typeDependency, contains(from.path, interface), contains(to.scheme, "variable") || contains(to.scheme, "field") };
	
	//generate single type suggestion
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