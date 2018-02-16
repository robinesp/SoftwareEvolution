module lang::java::HashcodeContract

import lang::java::jdt::m3::AST;  // for Java trees
import lang::java::jdt::m3::Core; // for Java tables
import IO; // for println
import lang::java::Visualisation;
import Message;

loc equalsMethod = |java+method:///java/lang/Object/equals(java.lang.Object)|;
loc hashCodeMethod = |java+method:///java/lang/Object/hashCode()|;

set[Message] checkEqualsContract(M3 m) {
    overrides = (m.methodOverrides<to,from>)+;

    equals = overrides[equalsMethod];
    hashCodes = overrides[hashCodeMethod];

    classesWithEquals = {/*...TODO...*/};
    classesWithHashcodes = {/*...TODO...*/};
    
    violators = {{/*...TODO...*/ }};
    
    return { warning("hashCode not implemented", cl)
           | cl <- violators }; 
}