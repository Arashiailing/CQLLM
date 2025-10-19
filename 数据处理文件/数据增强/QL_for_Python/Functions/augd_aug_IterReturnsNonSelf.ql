/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects when an iterator's `__iter__` method fails to return self, violating the Python iterator protocol.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/iter-returns-non-self
 */

import python

/**
 * Retrieves the scope of the `__iter__` method for a given class.
 * @param iterCls - The iterator class to examine
 * @return - The scope of the `__iter__` method
 */
Function getIterMethodScope(ClassValue iterCls) { 
    result = iterCls.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * Determines if the returned value matches the function's first parameter (typically `self`).
 * @param retVal - The return value to check
 * @param func - The function containing the return value
 */
predicate isSelfReturn(Name retVal, Function func) { 
    retVal.getVariable() = func.getArg(0).(Name).getVariable() 
}

/**
 * Checks if a function has a fallthrough node (i.e., no explicit return).
 * @param func - The function to check
 */
predicate hasFallthroughNode(Function func) {
    exists(func.getFallthroughNode())
}

/**
 * Checks if a function has a return statement without a value.
 * @param func - The function to check
 */
predicate hasReturnWithoutValue(Function func) {
    exists(Return returnStmt | 
        returnStmt.getScope() = func and 
        not exists(returnStmt.getValue())
    )
}

/**
 * Checks if a function has a return statement that returns a non-self value.
 * @param func - The function to check
 */
predicate hasNonSelfReturn(Function func) {
    exists(Return returnStmt | 
        returnStmt.getScope() = func and 
        not isSelfReturn(returnStmt.getValue(), func)
    )
}

/**
 * Determines if a function returns a non-self value or has no return value.
 * @param func - The function to check
 */
predicate returnsNonSelf(Function func) {
    hasFallthroughNode(func) or
    hasNonSelfReturn(func) or
    hasReturnWithoutValue(func)
}

// Main query: Find all iterator classes that violate the iterator protocol
from ClassValue iterCls, Function iterFunc
// Condition 1: iterCls is an iterator
where iterCls.isIterator() and 
      // Condition 2: iterFunc is the `__iter__` method of iterCls
      iterFunc = getIterMethodScope(iterCls) and 
      // Condition 3: iterFunc returns non-self or has no return value
      returnsNonSelf(iterFunc)
// Select the class iterCls, error message, function iterFunc and its name
select iterCls, 
       "Class " + iterCls.getName() + " is an iterator but its $@ method does not return 'self'.",
       iterFunc, iterFunc.getName()