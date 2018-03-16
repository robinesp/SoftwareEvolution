module FlowGraphsAndClassDiagrams

import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;
import List;
import Relation;
import lang::java::m3::Core;

import IO;
import vis::Figure; 
import vis::Render;

alias OFG = rel[loc from, loc to];

OFG buildGraph(FlowProgram p, M3 m) 
  = { <as[i], fps[i]> | newAssign(x, cl, c, as) <- p.statements, constructor(c, fps) <- p.decls, i <- index(as) }
  + { <cl + "this", x> | newAssign(x, cl, _, _) <- p.statements }
  + { <cl, x> | assign(x, _, cl) <- p.statements }
  + { <cl + "this", x> | call(x, cl, _, _, _) <- p.statements }
  + { <cl + "this", x> | <x, cl> <- m.typeDependency }
  ;