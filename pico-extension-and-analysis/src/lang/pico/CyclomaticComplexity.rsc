module lang::pico::CyclomaticComplexity

import lang::pico::MyPico;
import ParseTree;

loc example = |project://pico-extension-and-analysis/src/lang/pico/fac.pico|;

int cc(loc p) = cc(parse(#start[Program], p));

int cc(start[Program] program) {
   int result = 1;
   
   visit (program) {
     // matching by example "concrete patterns":
     case (Statement) `while <Expression e> do
                      '  <{Statement ";"}* s>
                      'od` :
                       
       result += 1;
     //case (Statement) `if <Expression e> then
     //                 '  <{Statement ";"}* s>
     //                 'fi` :
     //  result += 1;
     //case (Statement) `if <Expression e> then
     //                 '  <{Statement ";"}* s>
     //                 'else
     //                 '  <{Statement ";"}* t> 
     //                 'fi` :
     //  result += 1;
            
     // alternative implementation:       
     //case Statement x: 
     //  result += x is loop || x is cond ? 1 : 0;  
   }

   return result;
}

int funkyCC(start[Program] program)
  = (1 | it + 1 | /Statement child := program,
     child is loop || child is cond);

int spaces(start[Program] program) 
  = (0 | it + 1 | /char(32) := program);
  
