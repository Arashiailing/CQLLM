/**
 * @name Unreachable 'except' block
 * @description Detects except blocks that are unreachable due to incorrect handler ordering.
 *              This occurs when a general exception handler (catching a parent exception class) 
 *              appears before a specific handler (catching a child exception class) in the same try statement.
 *              As a result, the specific handler becomes unreachable because the general handler
 *              will always intercept the exception first.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// Retrieves the exception class associated with an exception handler
ClassValue getHandledExceptionClass(ExceptStmt exceptHandler) { 
  exceptHandler.getType().pointsTo(result) 
}

// Identifies cases where a general exception handler is positioned before
// a more specific handler within the same try statement
predicate findIncorrectExceptionHandlerOrder(ExceptStmt earlierHandler, ClassValue broaderException, 
                                            ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIdx, int laterIdx, Try tryStatement |
    // Both handlers must be part of the same try statement with correct ordering
    earlierHandler = tryStatement.getHandler(earlierIdx) and
    laterHandler = tryStatement.getHandler(laterIdx) and
    earlierIdx < laterIdx and
    // Get the exception types and verify inheritance relationship
    broaderException = getHandledExceptionClass(earlierHandler) and
    narrowerException = getHandledExceptionClass(laterHandler) and
    broaderException = narrowerException.getASuperType()
  )
}

// Query to find all unreachable exception handlers caused by incorrect ordering
from ExceptStmt laterHandler, ClassValue narrowerException, 
     ExceptStmt earlierHandler, ClassValue broaderException
where findIncorrectExceptionHandlerOrder(earlierHandler, broaderException, 
                                        laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()