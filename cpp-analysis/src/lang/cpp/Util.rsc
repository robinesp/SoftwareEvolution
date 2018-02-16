module lang::cpp::Util

import Exception;
import lang::cpp::AST;

Declaration stripIncludes(Declaration tu) = tu[declarations=[d | d <- tu.declarations, tu.src.top == d.src.top]];

rel[loc, loc] containment(Declaration ast) = { <ds.decl, declarator.decl> | /DeclSpecifier ds := ast , ds is struct || ds is class, Declaration d <- ds.members, d has declarators, Declarator declarator <- d.declarators }
  //+ other constructors
  //+ templates
  //+ ...
  ;