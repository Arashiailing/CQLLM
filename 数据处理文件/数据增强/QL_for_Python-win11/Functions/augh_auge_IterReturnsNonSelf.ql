/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects iterator classes whose `__iter__` method fails to return self instance, violating the iterator protocol.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// Retrieve the `__iter__` method definition for a given class
Function getIterMethod(ClassValue cls) { 
    result = cls.lookup("__iter__").(FunctionValue).getScope() 
}

// Check if a name node refers to the 'self' parameter of a method
predicate isSelfReference(Name nameNode, Function method) { 
    nameNode.getVariable() = method.getArg(0).(Name).getVariable() 
}

// Check if a method has an implicit return (no explicit return statement)
predicate hasImplicitReturn(Function method) {
    exists(method.getFallthroughNode())
}

// Check if a method has explicit return statements that don't return self
predicate hasNonSelfReturn(Function method) {
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not isSelfReference(returnStmt.getValue(), method)
    )
}

// Check if a method has return statements without values (returning None)
predicate hasEmptyReturn(Function method) {
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not exists(returnStmt.getValue())
    )
}

// Check if a method doesn't return self instance in any return path
predicate returnsNonSelfInstance(Function method) {
    hasImplicitReturn(method) or
    hasNonSelfReturn(method) or
    hasEmptyReturn(method)
}

// Main query logic
from ClassValue iteratorCls, Function iterMethodImpl
where 
    iteratorCls.isIterator() and 
    iterMethodImpl = getIterMethod(iteratorCls) and 
    returnsNonSelfInstance(iterMethodImpl)
// Format output results
select iteratorCls, 
    "Iterator class " + iteratorCls.getName() + " has a $@ method that doesn't return 'self'", 
    iterMethodImpl, iterMethodImpl.getName()