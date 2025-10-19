/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never be executed because a more general
 *              exception handler appears before them in the same try statement.
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
 * Extracts the exception class associated with an exception handler.
 * This helper function establishes a mapping between an ExceptStmt node
 * and its corresponding ClassValue representing the handled exception type.
 * @param exceptionHandler - The exception handler statement to be analyzed
 * @return - The ClassValue that represents the exception type handled by the block
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

/**
 * Checks if two exception handlers within the same try statement are ordered incorrectly.
 * An incorrect order occurs when a handler for a general exception type appears before
 * a handler for a more specific exception type that inherits from the general one.
 * @param precedingHandler - The exception handler that appears first in the code
 * @param generalException - The general exception type handled by precedingHandler
 * @param subsequentHandler - The exception handler that appears later in the code
 * @param specificException - The specific exception type handled by subsequentHandler
 */
predicate exceptionHandlersInWrongOrder(ExceptStmt precedingHandler, ClassValue generalException, 
                                       ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // Verify both handlers belong to the same try statement and are in the correct sequence
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    precedingIndex < subsequentIndex
  ) and
  // Retrieve the exception types for both handlers
  generalException = getHandledExceptionClass(precedingHandler) and
  specificException = getHandledExceptionClass(subsequentHandler) and
  // Confirm inheritance relationship (general exception is a superclass of the specific one)
  generalException = specificException.getASuperType()
}

// Main query to identify all unreachable exception handlers
from ExceptStmt subsequentHandler, ClassValue specificException, 
     ExceptStmt precedingHandler, ClassValue generalException
where exceptionHandlersInWrongOrder(precedingHandler, generalException, 
                                  subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()