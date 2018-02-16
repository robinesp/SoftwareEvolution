module Main

import IO;
import String;
import Set;
import analysis::stemming::Snowball;

list[str] wordsInFile(loc file) 
  = [ word | /<word:[a-zA-Z]+>/ := readFile(file)];
  
list[str] stemAll(list[str] words) 
  = [stem(x) | x <- words];
  
void readRequirements() {

	//load requirements from files
	highFiles = |project://Assignment1/data/modis/high|.ls;
	lowFiles = |project://Assignment1/data/modis/low|.ls;
	
	highReqs = [];
	lowReqs = [];
	
	for (f <- highFiles)
		highReqs += [wordsInFile(f)];
	
	for (f <- lowFiles)
		lowReqs += [wordsInFile(f)];
	
	
	//load list of stop words and filter requirements
	stopWordsFile = |project://Assignment1/data/stop-word-list.txt|;
	stopWords = wordsInFile(stopWordsFile);
	
	filtered = [];
	for (req <- highReqs)
		filtered += [[ toLowerCase(word) | word <- req, toLowerCase(word) notin stopWords ]];
	highReqs = filtered;
		
	filtered = [];
	for (req <- lowReqs)
		filtered += [[ toLowerCase(word) | word <- req, toLowerCase(word) notin stopWords ]];
	lowReqs = filtered;
	
	
	//apply snowball stemming
	stemmed = [];
	for (req <- highReqs)
		stemmed += [stemAll(req)];
	highReqs = stemmed;
		
	stemmed = [];
	for (req <- lowReqs)
		stemmed += [stemAll(req)];
	lowReqs = stemmed;
	
	
	//create master vocabulary
	vocabulary = {};
	for (req <- highReqs)
		vocabulary += { word | word <- req };
	for (req <- lowReqs)
		vocabulary += { word | word <- req };
		
	print(sort(vocabulary));
}


void startTool() {
	readRequirements();
}