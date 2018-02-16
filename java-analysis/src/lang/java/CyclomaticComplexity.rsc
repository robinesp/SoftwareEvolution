module lang::java::CyclomaticComplexity

import lang::java::jdt::m3::AST;  // for Java trees
import lang::java::jdt::m3::Core; // for Java tables
import IO; // for println
import lang::java::Visualisation;
 
public loc elib = |project://eLib|;
public loc pdb  = |project://org.eclipse.imp.pdb.values|;
public loc snakes = |project://snakes-and-ladders-java|;

M3 getModel(loc p) 
  = createM3FromEclipseProject(p);
  
void init(loc l) {
  createM3FromEclipseProject(l);
  println("Initialized name lookup for <l>");
} 

rel[loc method, int metric] salcc() = projectcc(|project://snakes-and-ladders-java|);

rel[loc method, int metric] projectcc(loc project) 
  = { <d, calcCC(body)> | /method(_, _, _, _, Statement body, decl=d) := createAstsFromEclipseProject(project, true)};

int calcCC(Statement body) {
        int result = 1;
        visit (body) {
                case \if(_,_) : result += 1;
                case \for(_,_,_,_) : result += 1;
                case \case(_,_) : result += 1;
                case \if(_,_,_) : result += 1;
                case \while(_,_) : result += 1;
                // TODO: add the missing cases
        }
        return result;
}



