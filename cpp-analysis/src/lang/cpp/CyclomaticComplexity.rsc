module lang::cpp::CyclomaticComplexity

import lang::cpp::AST;

str system = "mac-xcode"; // or "vs-12", "mingw", "mac"

Declaration saltree()
  = parseCpp(|project://snakes-and-ladders-cpp/main.cpp|, includePaths=classPaths["mac-xcode"]);
  
  