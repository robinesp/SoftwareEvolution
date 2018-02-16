module lang::java::ArchitectureConformance

import Message;
import lang::java::m3::Core;
import lang::java::jdt::m3::Core;
import Relation;
import IO;

// M3 pdb = createM3FromEclipseProject(|project://pdb.values|);

public rel[loc,loc] dontTouch = {
    <|java+package:///org/eclipse/imp/pdb/facts/impl/fast|, |java+package:///org/eclipse/imp/pdb/facts/impl/persistent|>,
    <|java+package:///org/eclipse/imp/pdb/facts/impl/fast|, |java+package:///org/eclipse/imp/pdb/facts/impl/primitive|>,
    <|java+package:///org/eclipse/imp/pdb/facts/impl/persistent|,|java+package:///org/eclipse/imp/pdb/facts/impl/reference|>,
    <|java+package:///org/eclipse/imp/pdb/facts/impl/util/collections|,|java+package:///org/eclipse/imp/pdb/facts/impl/fast|>,
    <|java+package:///org/eclipse/imp/pdb/facts/impl/util/collections|,|java+package:///org/eclipse/imp/pdb/facts/impl/persistent|>,
    <|java+package:///org/eclipse/imp/pdb/facts/impl/util/collections|,|java+package:///org/eclipse/imp/pdb/facts/impl/reference|>
};

set[Message] detectViolations(M3 m, rel[loc,loc] checkFor) {
    containmentTransitive = m.containment+;
    checkForTransitive = {  *(containmentTransitive[f] * containmentTransitive[t]) |  <f,t> <- checkFor };
    allUses = (m.uses + m.fieldAccess + m.methodInvocation + m.typeDependency);
    
    return { error("<f> shouln\'t use <t>", f) | <f,t> <-  checkForTransitive & allUses};
}