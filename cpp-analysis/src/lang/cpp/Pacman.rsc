module lang::cpp::Pacman

import util::Resources;
import lang::cpp::AST;
import IO;
import lang::cpp::Util;

@memo
Declaration player(int i) 
  = stripIncludes(parseCpp(|project://pacman-cpp/Player.cpp|, 
      includePaths=classPaths["mac-xcode"]+ [location(|project://pacman-cpp/Bool-Engine|), location(|project://pacman-cpp/|)]));