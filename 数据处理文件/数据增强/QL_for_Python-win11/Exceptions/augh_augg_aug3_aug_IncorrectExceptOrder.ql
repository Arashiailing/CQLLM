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
 * @param exceptionHandler - The exception statement to analyze
 * @return The class value representing the handled exception type
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

/**
 * Identifies problematic exception handler ordering where a general exception
 * is caught before a specific one, rendering the specific handler unreachable.
 * @param firstHandler - The exception handler that appears first in code
 * @param generalException - The general exception class handled earlier
 * @param secondHandler - The exception handler that appears later in code
 * @param specificException - The specific exception class handled later
 */
predicate findExceptOrderingIssue(ExceptStmt firstHandler, ClassValue generalException, 
                                 ExceptStmt secondHandler, ClassValue specificException) {
  exists(int firstIndex, int secondIndex, Try tryStmt |
    // Both handlers must belong to the same try block
    firstHandler = tryStmt.getHandler(firstIndex) and
    secondHandler = tryStmt.getHandler(secondIndex) and
    // Verify sequence: first handler precedes second handler
    firstIndex < secondIndex and
    // Extract exception types from both handlers
    generalException = getHandledExceptionClass(firstHandler) and
    specificException = getHandledExceptionClass(secondHandler) and
    // Confirm inheritance: general exception is a superclass
    generalException = specificException.getASuperType()
  )
}

// Main query to detect all unreachable exception handlers
from ExceptStmt secondHandler, ClassValue specificException, 
     ExceptStmt firstHandler, ClassValue generalException
where findExceptOrderingIssue(firstHandler, generalException, 
                             secondHandler, specificException)
select secondHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), firstHandler, "except block", generalException, generalException.getName()