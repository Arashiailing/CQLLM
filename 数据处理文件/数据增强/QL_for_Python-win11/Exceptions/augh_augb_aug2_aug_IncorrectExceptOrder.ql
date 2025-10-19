/**
 * @name Unreachable 'except' block
 * @description Identifies exception handling blocks that cannot be executed due to incorrect ordering
 *              where general exception types are caught before specific types that inherit from them.
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
 * @param exceptHandler - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by this block
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptHandler) { 
  exceptHandler.getType().pointsTo(result) 
}

/**
 * Detects exception handlers with incorrect ordering where a general exception
 * is caught before a specific exception that inherits from it.
 * @param earlierHandler - The earlier exception handler in the code sequence
 * @param generalException - The general exception type handled by earlierHandler
 * @param laterHandler - The later exception handler in the code sequence
 * @param specificException - The specific exception type handled by laterHandler
 */
predicate findIncorrectlyOrderedHandlers(ExceptStmt earlierHandler, ClassValue generalException, 
                                        ExceptStmt laterHandler, ClassValue specificException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Ensure handlers are in the same try block and in the correct sequence
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    earlierIndex < laterIndex
  ) and
  // Get the exception types for both handlers
  generalException = getHandledExceptionClass(earlierHandler) and
  specificException = getHandledExceptionClass(laterHandler) and
  // Verify inheritance relationship (general is a superclass of specific)
  generalException = specificException.getASuperType()
}

// Main query that identifies unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue generalException
where findIncorrectlyOrderedHandlers(earlierHandler, generalException, 
                                    laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", generalException, generalException.getName()