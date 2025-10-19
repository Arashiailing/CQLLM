/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

/**
 * Retrieves the exception class associated with an exception handler.
 * This helper function maps an ExceptStmt to its corresponding ClassValue.
 * @param exceptBlock - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by the block
 */
ClassValue getExceptionClass(ExceptStmt exceptBlock) { 
  exceptBlock.getType().pointsTo(result) 
}

/**
 * Determines if there is an incorrect order of exception handlers.
 * This occurs when a handler for a general exception type precedes a handler
 * for a more specific exception type that inherits from the general one.
 * @param firstHandler - The exception handler that appears first in the code
 * @param generalEx - The general exception type handled by firstHandler
 * @param secondHandler - The exception handler that appears later in the code
 * @param specificEx - The specific exception type handled by secondHandler
 */
predicate hasIncorrectExceptOrder(ExceptStmt firstHandler, ClassValue generalEx, 
                                 ExceptStmt secondHandler, ClassValue specificEx) {
  exists(int firstIndex, int secondIndex, Try tryBlock |
    // Both handlers belong to the same try statement and are in the correct order
    firstHandler = tryBlock.getHandler(firstIndex) and
    secondHandler = tryBlock.getHandler(secondIndex) and
    firstIndex < secondIndex
  ) and
  // Get the exception types for both handlers
  generalEx = getExceptionClass(firstHandler) and
  specificEx = getExceptionClass(secondHandler) and
  // Check inheritance relationship (general exception is a superclass of the specific one)
  generalEx = specificEx.getASuperType()
}

// Main query to find all unreachable exception handlers
from ExceptStmt secondHandler, ClassValue specificEx, 
     ExceptStmt firstHandler, ClassValue generalEx
where hasIncorrectExceptOrder(firstHandler, generalEx, 
                             secondHandler, specificEx)
select secondHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificEx, specificEx.getName(), firstHandler, "except block", generalEx, generalEx.getName()