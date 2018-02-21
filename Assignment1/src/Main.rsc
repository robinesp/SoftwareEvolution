module Main

import IO;
import String;
import Set;
import List;
import Exception;
import util::Math;
import analysis::stemming::Snowball;

list[str] wordsInFile(loc file) 
  = [ word | /<word:[a-zA-Z]+>/ := readFile(file)];
  
list[str] stemAll(list[str] words) 
  = [stem(x) | x <- words];
  
num cosineSimilarity(list[num] X, list[num] Y) {
	XY = 0.0;
    X2 = 0.0;
    Y2 = 0.0;
    if (size(X) != size(Y)) {
    	println("Error: the two vectors have different length.");
    	return -1;
    }
    for (int i <- [0 .. size(X)]) {
        XY += X[i] * Y[i];
        X2 += pow(X[i], 2);
        Y2 += pow(Y[i], 2);
    }   
    return XY / (sqrt(X2) * sqrt(Y2));;
}
  
void detect(loc highFilesDir, loc lowFilesDir, int filterType) {

	//load requirements from files
	list[loc] highFiles;
	list[loc] lowFiles;
	
	try {
		highFiles = highFilesDir.ls;
		lowFiles = lowFilesDir.ls;
	} 	catch PathNotFound(e) :  { println("Error: incorrect directory path."); return; }
		catch IO(e) : { println("Error: invali directory."); return; }
	
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

	//vector representation
	highReqsVec = [];
	lowReqsVec = [];
	n = size(highReqs) + size(lowReqs);
	
	for (req <- highReqs) {
		vec = [];
		freq = distribution(req);
		for (word <- sort(vocabulary)) {
			if (word notin req) vec += 0;
			else {
				tf = freq[word];
				d = 0.0;
				for (r <- highReqs + lowReqs)
					if (word in r) d += 1;
				idf = log2(n/d);
				vec += tf * idf;
			}
		}
		highReqsVec += [vec];
	}
	
	for (req <- lowReqs) {
		vec = [];
		freq = distribution(req);
		for (word <- sort(vocabulary)) {
			if (word notin req) vec += 0;
			else {
				tf = freq[word];
				d = 0.0;
				for (r <- highReqs + lowReqs)
					if (word in r) d += 1;
				idf = log2(n/d);
				vec += tf * idf;
			}
		}
		lowReqsVec += [vec];
	}
	
	
	//compute similarity matrix using cosine similarity
	matrix = [];
	for (h <- highReqsVec) {
		row = [];
		for (l <- lowReqsVec) {
			row += cosineSimilarity(h, l);
		}
		matrix += [row];
	}
		
		
	//filter requirements according to flag and write to file
	resultFile = |project://Assignment1/data/trace-links.txt|;
	writeFile(resultFile, "");
	
	switch (filterType) {
		case 1: {
			for (int i <- [0 .. size(highFiles)]) {
				appendToFile(resultFile,"%\n");
				appendToFile(resultFile,highFiles[i].file);
				for (int j <- [0 .. size(lowFiles)]) {
					if (matrix[i][j] >= 0) appendToFile(resultFile,"\t<lowFiles[j].file>");
				}
				appendToFile(resultFile,"\n");
			}
		}	
		case 2: {
			for (int i <- [0 .. size(highFiles)]) {
				appendToFile(resultFile, "%\n");
				appendToFile(resultFile,highFiles[i].file);
				
				orderedVecs = reverse(sort(matrix[i]));
				max4 = [x | num x <- slice(orderedVecs, 0, 4), x > 0];				
				indices = [];				
				for (num val <- max4)
					indices += indexOf(matrix[i], val);
			
				for (int j <- indices)
					appendToFile(resultFile,"\t<lowFiles[j].file>");
				appendToFile(resultFile,"\n");
			}
		}
		case 3: {
			for (int i <- [0 .. size(highFiles)]) {
				appendToFile(resultFile,"%\n");
				appendToFile(resultFile,highFiles[i].file);
				for (int j <- [0 .. size(lowFiles)]) {
					if (matrix[i][j] >= 0.25) appendToFile(resultFile,"\t<lowFiles[j].file>");
				}
				appendToFile(resultFile,"\n");
			}
		}
		case 4: {
			for (int i <- [0 .. size(highFiles)]) {
				appendToFile(resultFile,"%\n");
				appendToFile(resultFile,highFiles[i].file);
				
				orderedVecs = reverse(sort(matrix[i]));
				maxSim = orderedVecs[0];
				
				for (int j <- [0 .. size(lowFiles)]) {
					if (matrix[i][j] >= 0.67 * maxSim) appendToFile(resultFile,"\t<lowFiles[j].file>");
				}
				appendToFile(resultFile,"\n");
			}
		}
		case 5: {
			for (int i <- [0 .. size(highFiles)]) {
				appendToFile(resultFile,"%\n");
				appendToFile(resultFile,highFiles[i].file);
				
				orderedVecs = reverse(sort(matrix[i]));
				maxSim = orderedVecs[0];
				
				for (int j <- [0 .. size(lowFiles)]) {
					if (matrix[i][j] >= 0.5 * maxSim) appendToFile(resultFile,"\t<lowFiles[j].file>");
				}
				appendToFile(resultFile,"\n");
			}
		}
		default: println("Error: incorrect filtering flag.");
	}
}


void runTool() {
	detect(|project://Assignment1/data/modis/high|, |project://Assignment1/data/modis/low|, 2);
}

void evaluateTool() {
	evaluate(|project://Assignment1/data/modis/high|, |project://Assignment1/data/modis/low|, 1, |project://Assignment1/data/modis/handtrace.txt|);	
}

void evaluate(loc highFilesDir, loc lowFilesDir, int filterType, loc traceLinkFile) {
	int tp = 0; // true positives
	int fp = 0; // false positives
	int fn = 0; // false negatives

	// read in the manually identified trace-links and do some preparation
	handTracesFile = readFile(traceLinkFile);	
	handTraces = replaceAll(handTracesFile, "\n", "");
	handTracesList = split("%", handTraces);
	
	// run the tool
	detect(highFilesDir, lowFilesDir, filterType);
	
	// read in the trace-links predicted by the tool and do some preparation
	resultFile = |project://Assignment1/data/trace-links.txt|;
	tracesFile = readFile(resultFile);
	traces = replaceAll(tracesFile, "\n", "");
	tracesList = split("%", traces);
	
	// for each high-level requirement, find this requirement in both the file recording
	// manually constructed trace-links and the tool constructed trace-links
	for (h <- handTracesList) {
		if(!isEmpty(h)) {
			corrh = replaceAll(h, " ", "\t");
			handTraceLink = split("\t", corrh);
			for (t <- tracesList) {
				traceLink = split("\t", t);
				if(trim(handTraceLink[0]) == trim(traceLink[0])) {
					int matches = 0; // matches of low-level requirements for a high-level requirement
					
					// check if the same low-level requirements are detected
					for(int n <- [1 .. size(handTraceLink)]) {
						for(w <- traceLink) {
							if(trim(handTraceLink[n]) == trim(w)) {
								matches = matches + 1;								
							}
						}
					}
					tp = tp + matches;
					fp = fp + (size(traceLink) - 1 - matches);
					fn = fn + (size(handTraceLink) - 1 - matches);
				}
			}
			
		}
	}
	
	// printing the confusion matrix
	println("\t\t\t\ttl identified man \t tl not-identified man");
	println("tl predicted by tool \t\t\t <tp> \t\t\t <fp>");
	println("tl not predicted by tool \t\t <fn>");
	println();
	
	// recall
	println("recall: <tp / toReal(tp + fn)>");
	
	// precision
	println("precision: <tp / toReal(tp + fp)>");
	
	
}