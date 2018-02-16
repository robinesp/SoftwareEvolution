/*******************************************************************************
* Copyright (c) 2008 CWI.
* All rights reserved. This program and the accompanying materials
* are made available under the terms of the Eclipse Public License v1.0
* which accompanies this distribution, and is available at
* http://www.eclipse.org/legal/epl-v10.html
*
* Contributors:
*    jurgen@vinju.org
*******************************************************************************/
package org.eclipse.imp.pdb.facts.visitors;

import org.eclipse.imp.pdb.facts.IBool;
import org.eclipse.imp.pdb.facts.IConstructor;
import org.eclipse.imp.pdb.facts.IDateTime;
import org.eclipse.imp.pdb.facts.IExternalValue;
import org.eclipse.imp.pdb.facts.IInteger;
import org.eclipse.imp.pdb.facts.IList;
import org.eclipse.imp.pdb.facts.IMap;
import org.eclipse.imp.pdb.facts.INode;
import org.eclipse.imp.pdb.facts.IRational;
import org.eclipse.imp.pdb.facts.IReal;
import org.eclipse.imp.pdb.facts.ISet;
import org.eclipse.imp.pdb.facts.ISourceLocation;
import org.eclipse.imp.pdb.facts.IString;
import org.eclipse.imp.pdb.facts.ITuple;

/**
 * Extend this class to easily create a reusable generic visitor implementation.
 *
 */
public abstract class VisitorAdapter<T, E extends Throwable> implements IValueVisitor<T,E> {
	protected IValueVisitor<T,E> fVisitor;

	public VisitorAdapter(IValueVisitor<T,E> visitor) {
		this.fVisitor = visitor;
	}

	public T visitReal(IReal o) throws E {
		return fVisitor.visitReal(o);
	}

	public T visitInteger(IInteger o) throws E {
		return fVisitor.visitInteger(o);
	}

	public T visitRational(IRational o) throws E {
		return fVisitor.visitRational(o);
	}

	public T visitList(IList o) throws E {
		return fVisitor.visitList(o);
	}

	public T visitMap(IMap o) throws E {
		return fVisitor.visitMap(o);
	}

	public T visitRelation(ISet o) throws E {
		return fVisitor.visitRelation(o);
	}

	public T visitSet(ISet o) throws E {
		return fVisitor.visitSet(o);
	}

	public T visitSourceLocation(ISourceLocation o) throws E {
		return fVisitor.visitSourceLocation(o);
	}

	public T visitString(IString o) throws E {
		return fVisitor.visitString(o);
	}

	public T visitNode(INode o) throws E {
		return fVisitor.visitNode(o);
	}

	public T visitConstructor(IConstructor o) throws E {
		return fVisitor.visitNode(o);
	}
	
	public T visitTuple(ITuple o) throws E {
		return fVisitor.visitTuple(o);
	}
	
	public T visitBoolean(IBool o) throws E {
		return fVisitor.visitBoolean(o);
	}
	
	public T visitDateTime(IDateTime o) throws E {
		return fVisitor.visitDateTime(o);
	}
	@Override
	public T visitListRelation(IList o) throws E {
	  return fVisitor.visitListRelation(o);
	}
	@Override
	public T visitExternal(IExternalValue externalValue) throws E {
	  return fVisitor.visitExternal(externalValue);
	}
}
