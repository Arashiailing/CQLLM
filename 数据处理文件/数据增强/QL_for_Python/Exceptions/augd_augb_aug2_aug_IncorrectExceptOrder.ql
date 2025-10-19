/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable because general exceptions
 *              are caught before specific ones that inherit from them in the same try block.
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
 * @param exceptionHandler - The exception handler statement to examine
 * @return - The ClassValue representing the exception type handled by this handler
 */
ClassValue getExceptionClass(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

/**
 * Finds exception handlers with incorrect ordering where a general exception
 * is caught before a more specific one that inherits from it.
 * @param earlierHandler - The exception handler that appears first in the code
 * @param generalException - The general exception type handled by earlierHandler
 * @param laterHandler - The exception handler that appears later in the code
 * @param specificException - The specific exception type handled by laterHandler
 */
predicate hasIncorrectExceptOrder(ExceptStmt earlierHandler, ClassValue generalException, 
                                 ExceptStmt laterHandler, ClassValue specificException) {
  // Both handlers must belong to the same try block with earlierHandler appearing first
  exists(int earlierIdx, int laterIdx, Try tryStatement |
    earlierHandler = tryStatement.getHandler(earlierIdx) and
    laterHandler = tryStatement.getHandler(laterIdx) and
    earlierIdx < laterIdx
  ) and
  // Get the exception types for both handlers
  generalException = getExceptionClass(earlierHandler) and
  specificException = getExceptionClass(laterHandler) and
  // Verify inheritance relationship (generalException is a superclass of specificException)
  generalException = specificException.getASuperType()
}

// Main query that detects unreachable exception handlers due to improper ordering
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue generalException
where hasIncorrectExceptOrder(earlierHandler, generalException, 
                             laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", generalException, generalException.getName()