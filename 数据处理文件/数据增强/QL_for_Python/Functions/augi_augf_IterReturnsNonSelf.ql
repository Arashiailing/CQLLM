/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects iterator classes whose `__iter__` method fails to return self,
 *              which violates the iterator protocol in Python.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

// Helper function to retrieve the `__iter__` method from a given iterator class
Function getIteratorMethod(ClassValue iteratorClass) { 
    result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

// Predicate to verify if a name refers to the function's first parameter (self)
predicate isSelfReference(Name name, Function func) { 
    name.getVariable() = func.getArg(0).(Name).getVariable() 
}

// Predicate to identify functions that either:
// 1. Fall through without returning
// 2. Return a non-self value
// 3. Return without any value
predicate returnsInvalidValue(Function func) {
    // Case 1: Function has fallthrough node (no explicit return)
    exists(func.getFallthroughNode())
    or
    // Case 2 & 3: Function returns non-self or has empty return
    exists(Return retNode | 
        retNode.getScope() = func and 
        (
            not exists(retNode.getValue())  // Empty return
            or
            not isSelfReference(retNode.getValue(), func)  // Non-self return
        )
    )
}

// Main query to identify iterator classes with improper `__iter__` methods
from ClassValue iteratorClass, Function iterMethod
where 
    // Verify the class implements iterator protocol
    iteratorClass.isIterator() and 
    // Retrieve the __iter__ method implementation
    iterMethod = getIteratorMethod(iteratorClass) and 
    // Check for invalid return behavior in the method
    returnsInvalidValue(iterMethod)
// Report findings with contextual message
select iteratorClass, 
    "Class " + iteratorClass.getName() + 
    " is an iterator but its $@ method does not return 'self'.",
    iterMethod, iterMethod.getName()