/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable due to incorrect ordering.
 *              When a general exception is caught before a specific one, the specific handler
 *              becomes unreachable as the general handler will always match first.
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

/**
 * Extracts the exception class referenced by an exception handler.
 * @param handler - The exception statement to analyze
 * @return The class value representing the handled exception type
 */
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Identifies problematic exception handler ordering where a general exception
 * is caught before a specific one, rendering the specific handler unreachable.
 * @param earlierHandler - The exception handler that appears first in code
 * @param baseException - The general exception class handled earlier
 * @param laterHandler - The exception handler that appears later in code
 * @param derivedException - The specific exception class handled later
 */
predicate findExceptOrderingIssue(ExceptStmt earlierHandler, ClassValue baseException, 
                                 ExceptStmt laterHandler, ClassValue derivedException) {
  exists(int earlierIdx, int laterIdx, Try tryBlock |
    // Both handlers must belong to the same try block
    earlierHandler = tryBlock.getHandler(earlierIdx) and
    laterHandler = tryBlock.getHandler(laterIdx) and
    // Verify sequence: earlier handler precedes later handler
    earlierIdx < laterIdx and
    // Extract exception types from both handlers
    baseException = getHandledExceptionClass(earlierHandler) and
    derivedException = getHandledExceptionClass(laterHandler) and
    // Confirm inheritance: base exception is a superclass
    baseException = derivedException.getASuperType()
  )
}

// Main query to detect all unreachable exception handlers
from ExceptStmt laterHandler, ClassValue derivedException, 
     ExceptStmt earlierHandler, ClassValue baseException
where findExceptOrderingIssue(earlierHandler, baseException, 
                             laterHandler, derivedException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), earlierHandler, "except block", baseException, baseException.getName()