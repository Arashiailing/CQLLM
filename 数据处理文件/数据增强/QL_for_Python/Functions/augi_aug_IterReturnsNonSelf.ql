/**
 * @name Iterator does not return self from `__iter__` method
 * @description Detects iterator classes whose `__iter__` method fails to return self,
 *              violating the Python iterator protocol.
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
 * @param iteratorCls - The class to be examined
 * @return - The scope of the `__iter__` method
 */
Function getIterMethodScope(ClassValue iteratorCls) { 
    result = iteratorCls.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * Determines if a returned value corresponds to the first parameter (typically 'self')
 * of the containing function.
 * @param retVal - The returned value to be checked
 * @param method - The function containing the return value
 */
predicate isSelfReturn(Name retVal, Function method) { 
    retVal.getVariable() = method.getArg(0).(Name).getVariable() 
}

/**
 * Checks if a function has a fallthrough node (i.e., reaches the end without an explicit return).
 * @param method - The function to be examined
 */
predicate hasFallthroughNode(Function method) {
    exists(method.getFallthroughNode())
}

/**
 * Checks if a function contains a return statement without a value.
 * @param method - The function to be examined
 */
predicate hasReturnWithoutValue(Function method) {
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not exists(returnStmt.getValue())
    )
}

/**
 * Checks if a function has a return statement that returns a value other than self.
 * @param method - The function to be examined
 */
predicate hasNonSelfReturn(Function method) {
    exists(Return returnStmt | 
        returnStmt.getScope() = method and 
        not isSelfReturn(returnStmt.getValue(), method)
    )
}

/**
 * Determines if a function either has fallthrough, returns without value, or returns non-self.
 * @param method - The function to be examined
 */
predicate returnsNonSelf(Function method) {
    hasFallthroughNode(method) or
    hasReturnWithoutValue(method) or
    hasNonSelfReturn(method)
}

// Main query: Identify all iterator classes that violate the iterator protocol
from ClassValue iteratorCls, Function iterMthd
// Condition 1: iteratorCls is an iterator
where iteratorCls.isIterator() and 
      // Condition 2: iterMthd is the __iter__ method of iteratorCls
      iterMthd = getIterMethodScope(iteratorCls) and 
      // Condition 3: iterMthd method returns non-self or has no return value
      returnsNonSelf(iterMthd)
// Select the iterator class, error message, the method, and its name
select iteratorCls, 
       "Class " + iteratorCls.getName() + " is an iterator but its $@ method does not return 'self'.",
       iterMthd, iterMthd.getName()