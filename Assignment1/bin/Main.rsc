module Main

import IO;
import String;


list[str] wordsInFile(loc file) 
  = [ word | /<word:[a-zA-Z]+>/ := readFile(file)];
  
  
void readRequirements() {

	//load requirements from files
	highFiles = |project://Assignment1/data/modis/high|.ls;
	lowFiles = |project://Assignment1/data/modis/low|.ls;
	
	highReqs = [];
	lowReqs = [];
	
	for (f <- highFiles)
		highReqs = highReqs + [wordsInFile(f)];
	
	for (f <- lowFiles)
		lowReqs = lowReqs + [wordsInFile(f)];
	
	
	//load list of stop words and filter requirements
	stopWordsFile = |project://Assignment1/data/stop-word-list.txt|;
	stopWords = wordsInFile(stopWordsFile);
	
	filtered = [];
	for (req <- highReqs)
		filtered += [[ word | word <- req, toLowerCase(word) notin stopWords ]];
	highReqs = filtered;
		
	filtered = [];
	for (req <- lowReqs)
		filtered += [[ word | word <- req, toLowerCase(word) notin stopWords ]];
	lowReqs = filtered;
	
}


void startTool() {
	readRequirements();
}