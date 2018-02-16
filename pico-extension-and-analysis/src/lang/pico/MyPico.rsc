module lang::pico::MyPico

extend lang::pico::\syntax::Main;
import util::IDE;
import util::ResourceMarkers;
import Message; 

syntax Statement 
  = "for" Id id "in" Expression exp "do" {Statement ";"}* "od"
  ;


start[Program] parsePico(str input, loc src)
  = parse(#start[Program], input, src);
    
void registerPico() {
  registerLanguage("Pico", "pico", parsePico);
}

public loc facExample = |project://cuso-pico/src/lang/pico/fac.pico|;

rel[loc def, loc use] getUseDef(start[Program] program) {
   defs = {<name@\loc, "<name>"> | /(IdType) `<Id name> : <Type t>` := program};
   uses = {<"<name>", name@\loc> | /(Id) `<Id name>` := program};
   return (defs o uses) - {<x,x> | x <- defs<0>};
}

set[Message] getWarnings(start[Program] prog) {
   usedef = getUseDef(prog);
   defs = {<name@\loc, "<name>"> | /(IdType) `<Id name> : <Type t>` := prog};
   uses = {<name@\loc, "<name>"> | /(Id) `<Id name>` := prog};
   used = uses[usedef<use>];
   unused = defs<1> - used;
   
  return {warning("Alert! this is an unused identifier <n>", l) | <l,n> <- defs, n in unused};
}
  
anno rel[loc,loc] Tree@hyperlinks;
  
void registerPicoWithBenefits() {
  registerLanguage("Pico", "pico", parsePico);
  registerContributions("Pico", {
    annotator(Tree (Tree x) { 
      return x[@messages=getWarnings(x)][@hyperlinks=getUseDef(x)<use,def>]; 
    })
  });
}  