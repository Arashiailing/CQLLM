/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects iterator classes whose `__iter__` method fails to return self,
 *              violating the iterator protocol requirements.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// Helper: Retrieve the `__iter__` method definition for a given class
Function fetchIterMethod(ClassValue cls) { 
    result = cls.lookup("__iter__").(FunctionValue).getScope() 
}

// Helper: Determine if a name node refers to the 'self' parameter of a method
predicate isSelfParam(Name nameNode, Function method) { 
    nameNode.getVariable() = method.getArg(0).(Name).getVariable() 
}

// Helper: Check if a method fails to return the self instance
predicate failsToReturnSelf(Function method) {
    // Case 1: Method has implicit return (no explicit return statement)
    exists(method.getFallthroughNode())
    // Case 2: Method has explicit return but the value is not self
    or
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not isSelfParam(returnStmt.getValue(), method)
    )
    // Case 3: Method has explicit return with no value (equivalent to returning None)
    or
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not exists(returnStmt.getValue())
    )
}

// Main query: Find iterator classes with improperly implemented __iter__ methods
from ClassValue iterCls, Function iterDef
where 
    // Ensure the target class is an iterator
    iterCls.isIterator() and 
    // Obtain the __iter__ method of the class
    iterDef = fetchIterMethod(iterCls) and 
    // Verify the method does not return the self instance
    failsToReturnSelf(iterDef)
// Format and output the results
select iterCls, 
    "Iterator class " + iterCls.getName() + " has a $@ method that does not return 'self'", 
    iterDef, iterDef.getName()