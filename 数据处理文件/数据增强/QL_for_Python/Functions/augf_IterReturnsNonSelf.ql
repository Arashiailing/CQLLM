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

// Helper function to retrieve the scope of the `__iter__` method from a given class
Function getIterMethod(ClassValue targetClass) { 
    result = targetClass.lookup("__iter__").(FunctionValue).getScope() 
}

// Predicate to verify if a value refers to the function's first parameter (self)
predicate isSelfReference(Name value, Function f) { 
    value.getVariable() = f.getArg(0).(Name).getVariable() 
}

// Predicate to check if a function returns non-self or lacks a return statement
predicate returnsNonSelf(Function f) {
    // Case 1: Function has a fallthrough node (no explicit return)
    exists(f.getFallthroughNode())
    or
    // Case 2: Function returns a value that is not self
    exists(Return r | 
        r.getScope() = f and 
        not isSelfReference(r.getValue(), f)
    )
    or
    // Case 3: Function has a return statement without a value
    exists(Return r | 
        r.getScope() = f and 
        not exists(r.getValue())
    )
}

// Main query to identify iterator classes with improper `__iter__` methods
from ClassValue targetClass, Function iterFunc
where 
    // Ensure the class is an iterator
    targetClass.isIterator() and 
    // Get the __iter__ method of the class
    iterFunc = getIterMethod(targetClass) and 
    // Check if the method returns non-self or has no return
    returnsNonSelf(iterFunc)
// Report findings with appropriate message
select targetClass, 
    "Class " + targetClass.getName() + 
    " is an iterator but its $@ method does not return 'self'.",
    iterFunc, iterFunc.getName()