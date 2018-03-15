module Util

import IO;
import String;
import List;
import Set;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;
import FlowGraphsAndClassDiagrams;


loc getSmallestCommonSuperclass(set[loc] classes, M3 m) {
	//get hierarchy for each class
	chains = [];
	for(current <- classes) {
		list[loc] super;
		chain = [];
		do {
			chain += current;
			super = [ parent | <class, parent> <- m.extends, class==current ];
			if (size(super)>0)
				current = super[0];
		} while(size(super)>0);
		chains += [chain];
	}
	
	//find the smalles supertype occurring in all chains
	found = false;
	superclass = |java+class:///java/lang/Object/this|;
	for(el <- chains[0]) {
		for(chain <- chains[1..]) {
			if (!(el in chain)) {
				found = false;
				break;
			}
			found = true;
		}
		if(found==true) {
			superclass = el;
			break;
		}
	}
	
	return superclass;
}



set[loc] getKeyTypes(loc collection, M3 m) {

	//find first line in which the collection is linked to a key
	collectionName = split("/",collection.path)[size(split("/",collection.path))-1];
	location = [ file | <var, file> <- m.declarations, var==collection ][0];
	file_path = |<location.scheme>://<location.authority><location.path>|;
	file_content = readFile(file_path);
	whole_file = contains(file_content, "\r\n") ? split("\r\n",file_content) : split("\n",file_content);
	interesting_lines = [];
	for(line <- whole_file) {
		if(contains(line, collectionName) && (contains(line, "get") || contains(line, "put") || contains(line, "remove") || contains(line, "containsKey"))) {
			interesting_lines += line;
		}
	}
	
	//search for keys initialized in same line
	typeNames = {};
	for(l <- interesting_lines) {
		collection_index = findFirst(l, collectionName);
		l = l[collection_index..];
		parameters_index = findFirst(l, "(");
		l = trim(l[parameters_index+1..]);
		if (findFirst(l, "new")==0) {
			new_index = findFirst(l, "new");
			typeNames += split("(", split(" ", l[new_index+4..])[0])[0];
		}
	}
	
	//look for keys initialized or asigned in same file
	for(l <- interesting_lines) {
		collection_index = findFirst(l, collectionName);
		l = l[collection_index..];
		object_index = findFirst(l, "(");
		objectName = split(",", split(" ", l[object_index+1..])[0])[0];
		if(objectName=="new") continue;
		for(line <- whole_file) {
			if (contains(line, objectName) && contains(line, "new")) {
				new_index = findFirst(line, "new");
				typeNames += split("(", split(" ", line[new_index+4..])[0])[0];
				break;
			}
			else if (size(split(" ", line))>2 && split(" ", line)[1] == objectName) {
				typeNames += split(" ", trim(line))[0];
				break;
			}
		}
	}
	
	keyTypes = { |java+class:///java/lang/<typeName>/this| | typeName <- typeNames };
	return keyTypes;
}