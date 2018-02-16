module lang::java::FlowGraphs

import lang::java::jdt::m3::AST;
import lang::java::jdt::m3::Core;
import analysis::flow::ObjectFlow;
import lang::java::flow::JavaToObjectFlow;
import util::ValueUI;

loc exampleProject = |project://pdb.values|;
loc exampleFile = |project://pdb.values/src/org/eclipse/imp/pdb/facts/util/ShareableHashMap.java|;

void extractStuff() {
  // this first, also to make URI clicking work:
  model = createM3FromEclipseProject(exampleProject);

  // this is an ast to learn a flow model from:
  asts = createAstFromEclipseFile(exampleFile, true);
  text(asts); // show in an editor

  set[Declaration] simple = { d | /Declaration d := asts };
  text(simple); 

  // simplistic declaration extraction, see lang::java::flow::JavaToObjectFlow
  // for a full mapping of Java to a flow model.
  set[FlowDecl] decls 
    = { method(d.decl,[p.decl | p <- d.parameters]) | /d:method(_,name,_,_,_) := asts };
  text(decls);

  // simplistic call extraction
  set[FlowStm] calls 
    = { call(c.decl,|nothing:///|, r.decl, c.decl,[]) | /c:methodCall(_,r,_,args) := asts};
  text(calls);
  
  // real flow model extraction:
  ofg = createOFG({asts}); 
  text(ofg);  
}