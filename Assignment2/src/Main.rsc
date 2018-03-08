module Main

import IO;
import String;
import List;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;


void generate_suggestions(loc project) {
	
	m = createM3FromEclipseProject(project);
	set[Declaration] asts = createAstsFromFiles(toSet(project.ls), true);
	p = createOFG(asts);
	
}

void run() {
	generate_suggestions(|project://eLib/|);
}