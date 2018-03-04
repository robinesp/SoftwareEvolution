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
		catch IO(e) : { println("Error: invalid directory."); return; }
	
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
				
				int j = 0;
				map[str, num] dict = ();
				for (simValue <- matrix[i]) {
					dict += (lowFiles[j].file : simValue);
					j += 1;
				}
				
				max4 = [];
				for (int k <- [0 .. 4]) {
					maxValue = 0;
					maxReq = "";
					for(current <- dict) {
						if(dict[current] > maxValue) {
							maxValue = dict[current];
							maxReq = current;
						}
					}
					max4 += maxReq;
					dict -= (maxReq : maxValue);
					// n += 1;
				}
			
				for (str r <- max4)
					appendToFile(resultFile,"\t<r>");
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

void evaluate(loc highFilesDir, loc lowFilesDir, int filterType, loc traceLinkFile) {
	int tp = 0; // true positives
	int fp = 0; // false positives
	int fn = 0; // false negatives
	
	list[loc] highFiles = highFilesDir.ls;
	list[loc] lowFiles = lowFilesDir.ls; 
	int total = size(highFiles) * size(lowFiles);

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
	
	misClassFP = []; // list of false positive misclassifications
	misClassFN = []; // list of false negative misclassifications
	
	// for each high-level requirement, find this requirement in both the file recording
	// manually constructed trace-links and the tool constructed trace-links
	for (h <- handTracesList) {
		if(!isEmpty(h)) {
			corrh = replaceAll(h, " ", "\t");
			handTraceLink = split("\t", corrh);
			for (t <- tracesList) {
				traceLink = split("\t", t);
				mistakesFN = []; // list of false negative misclassifications for this one high-level requirement
				mistakesFP = []; // list of false positive misclassifications for this one high-level requirement
				
				// check if both highlevel requirements are the same
				if(trim(handTraceLink[0]) == trim(traceLink[0])) {
					int matches = 0; // matches of low-level requirements for a high-level requirement
					mistakesFP += traceLink[0];
					mistakesFP += ":";
					mistakesFP += traceLink[1 .. size(traceLink)]; 
					mistakesFN += handTraceLink[0];
					mistakesFN += ":";
					
					// check if the same low-level requirements are detected
					for(int n <- [1 .. size(handTraceLink)]) {
						bool check = true;
						for(int w <- [1 .. size(traceLink)]) {
							// if the same low-level requirements are detected, add one to matches
							// and update the misclassifications
							if(trim(handTraceLink[n]) == trim(traceLink[w])) {
								matches = matches + 1;
								ind = indexOf(mistakesFP, traceLink[w]);
								mistakesFP = delete(mistakesFP, ind);
								check = false;								
							} 
						}
						if(check) {
							mistakesFN += handTraceLink[n];
						}
					}
					misClassFP += intercalate(" ", mistakesFP);
					misClassFN += intercalate(" ", mistakesFN);

					// update the true positives, false positives, and false negatives
					tp = tp + matches;
					fp = fp + (size(traceLink) - 1 - matches);
					fn = fn + (size(handTraceLink) - 1 - matches);
				}
				
			}
		}
	}
	
	// printing the confusion matrix
	println();
	println("\t\t\t\ttl identified man \t tl not-identified man");
	println("tl predicted by tool \t\t\t <tp> \t\t\t <fp>");
	println("tl not predicted by tool \t\t <fn> \t\t\t <total - tp - fp - fn>");
	println();
	
	// recall
	println("recall: <tp / toReal(tp + fn) * 100>%");
	
	// precision
	println("precision: <tp / toReal(tp + fp) * 100>%");
	
	// printing of false negative misclassifications
	println();
	println("False negative misclassifications");
	for(m <- misClassFN) {
		println(m);
	}
	
	// printing of false positive misclassifications
	println();
	println("False positive misclassifications");
	for(m <- misClassFP) {
		println(m);
	}
	
	
}


// quick-run functions

void runTool() {
	detect(|project://Assignment1/data/modis/high|, |project://Assignment1/data/modis/low|, 1);
}

void evaluateTool() {
	evaluate(|project://Assignment1/data/modis/high|, |project://Assignment1/data/modis/low|, 1, |project://Assignment1/data/modis/handtrace.txt|);	
}