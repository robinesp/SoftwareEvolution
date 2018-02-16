module Main

import IO;

list[str] wordsInFile(loc file) 
  = [ word | /<word:[a-zA-Z]+>/ := readFile(file)];
  
 
void readRequirements() {
	highFiles = |project://Assignment1/data/modis/high|.ls;
	lowFiles = |project://Assignment1/data/modis/low|.ls;
	
	highReqs = [];
	lowReqs = [];
	
	for (f <- highFiles) {
		highReqs = highReqs + wordsInFile(f);
	}
	
	for (f <- lowFiles) {
		lowReqs = lowReqs + wordsInFile(f);
	}
	
	stopWordsFile = |project://Assignment1/data/stop-word-list.txt|;
	stopWords = wordsInFile(stopWordsFile);
	
	print("<stopWords>");
}

void detect() {
	readRequirements();
}