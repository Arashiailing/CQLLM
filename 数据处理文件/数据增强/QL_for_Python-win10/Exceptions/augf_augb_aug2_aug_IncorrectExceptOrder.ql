/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that cannot be executed because of incorrect ordering
 *              where broader exceptions are caught before more specific ones that derive from them.
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
 * @param exceptBlock - The exception handler statement to examine
 * @return - The ClassValue representing the exception type handled by this block
 */
ClassValue handledExceptionType(ExceptStmt exceptBlock) { 
  exceptBlock.getType().pointsTo(result) 
}

/**
 * Finds exception handlers with incorrect ordering where a broader exception
 * is caught before a more specific one that inherits from it.
 * @param earlierHandler - The exception handler that appears first in the code
 * @param generalException - The general exception type handled by earlierHandler
 * @param laterHandler - The exception handler that appears later in the code
 * @param specificException - The specific exception type handled by laterHandler
 */
predicate incorrectExceptionHandlerOrder(ExceptStmt earlierHandler, ClassValue generalException, 
                                        ExceptStmt laterHandler, ClassValue specificException) {
  exists(int earlierIdx, int laterIdx, Try tryStatement |
    // Ensure both handlers are part of the same try block and in sequence
    earlierHandler = tryStatement.getHandler(earlierIdx) and
    laterHandler = tryStatement.getHandler(laterIdx) and
    earlierIdx < laterIdx
  ) and
  // Get the exception types for both handlers
  generalException = handledExceptionType(earlierHandler) and
  specificException = handledExceptionType(laterHandler) and
  // Verify inheritance relationship (general is a superclass of specific)
  generalException = specificException.getASuperType()
}

// Primary query that identifies unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue generalException
where incorrectExceptionHandlerOrder(earlierHandler, generalException, 
                                   laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the broader $@ for $@ will always catch the exception first.",
  specificException, specificException.getName(), earlierHandler, "except block", generalException, generalException.getName()