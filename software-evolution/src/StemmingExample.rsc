module StemmingExample

import analysis::stemming::Snowball;
import IO;
import lang::csv::IO;
import Relation;
import analysis::statistics::Frequency;

set[str] wordsInFile(loc file) 
  = { word | /<word:[a-zA-Z]+>/ := readFile(file)};
  
set[str] stemAll(set[str] words) 
  = {stem(x) | x <- words};  
  
void demoStemming() {
  words = ["hello", "walking", "bikes", "entertained", "fietsen", "lopen", "gekocht"];
  
  for (w <- words) {
    println("The English stem of \'<w>\' is \'<stem(w, lang=english())>\',
            'while the Dutch stem is \'<stem(w, lang=dutch())>\'.");
  }
  
  
  println("As you can see, stemming algorithms are not perfect.");
}

void demoCSV() {
  rel[str word, int freq] words = {<"aap", 1>, <"noot", 2>, <"mies", 3>};
  
  file = |project://software-evolution/data/words.csv|;
  
  writeCSV(words, file, separator=";");
  
  x = readCSV(#rel[str first, int second], file, separator=";");
  
  println("same? <x == words>");
  println(x.first);
  
  //remove(file);
}
