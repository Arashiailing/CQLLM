/**
 * @name Iterator protocol violation: `__iter__` method does not return self
 * @description Identifies iterator classes that violate Python's iterator protocol by not returning self from their `__iter__` method.
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
 * Retrieves the function scope of the `__iter__` method for a specified iterator class.
 * @param iteratorClass - The iterator class to analyze
 * @return - Function scope of the `__iter__` method
 */
Function getIterMethodScope(ClassValue iteratorClass) { 
    result = iteratorClass.lookup("__iter__").(FunctionValue).getScope() 
}

/**
 * Verifies if a returned value corresponds to the function's first parameter (typically `self`).
 * @param returnedValue - The return value to validate
 * @param function - The function containing the return statement
 */
predicate isSelfReturn(Name returnedValue, Function function) { 
    returnedValue.getVariable() = function.getArg(0).(Name).getVariable() 
}

/**
 * Detects functions with implicit fallthrough (missing explicit return statement).
 * @param function - The function to inspect
 */
predicate hasFallthroughNode(Function function) {
    exists(function.getFallthroughNode())
}

/**
 * Identifies functions containing return statements without values.
 * @param function - The function to inspect
 */
predicate hasReturnWithoutValue(Function function) {
    exists(Return returnStmt | 
        returnStmt.getScope() = function and 
        not exists(returnStmt.getValue())
    )
}

/**
 * Finds functions with return statements returning non-self values.
 * @param function - The function to inspect
 */
predicate hasNonSelfReturn(Function function) {
    exists(Return returnStmt | 
        returnStmt.getScope() = function and 
        not isSelfReturn(returnStmt.getValue(), function)
    )
}

/**
 * Determines if a function violates iterator protocol by not returning self.
 * @param function - The function to validate
 */
predicate returnsNonSelf(Function function) {
    hasFallthroughNode(function) or
    hasNonSelfReturn(function) or
    hasReturnWithoutValue(function)
}

// Main query: Identify iterator classes violating the protocol
from ClassValue iteratorClass, Function iterMethod
where 
    // Condition 1: Verify iterator class
    iteratorClass.isIterator() and 
    // Condition 2: Resolve __iter__ method
    iterMethod = getIterMethodScope(iteratorClass) and 
    // Condition 3: Check for protocol violation
    returnsNonSelf(iterMethod)
// Generate results with error message and method details
select iteratorClass, 
       "Iterator class " + iteratorClass.getName() + " violates protocol: $@ does not return 'self'.",
       iterMethod, iterMethod.getName()