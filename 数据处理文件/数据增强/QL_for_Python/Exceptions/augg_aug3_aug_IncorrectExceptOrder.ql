/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that will never execute due to improper ordering.
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
 * Retrieves the exception class referenced by an exception handler.
 * @param handler - The exception statement to process
 * @return The class value representing the handled exception type
 */
ClassValue extractExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Detects problematic exception handler ordering where a broader exception
 * is handled before a more specific one, rendering the specific handler unreachable.
 * @param earlierHandler - The exception handler that appears first in code
 * @param broaderException - The general exception class handled earlier
 * @param laterHandler - The exception handler that appears later in code
 * @param specificException - The specific exception class handled later
 */
predicate detectExceptOrderingIssue(ExceptStmt earlierHandler, ClassValue broaderException, 
                                   ExceptStmt laterHandler, ClassValue specificException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers must be part of the same try statement
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    // Ensure proper sequence: earlier handler comes before later handler
    earlierIndex < laterIndex and
    // Extract exception types from both handlers
    broaderException = extractExceptionClass(earlierHandler) and
    specificException = extractExceptionClass(laterHandler) and
    // Verify inheritance relationship: broader exception is a superclass
    broaderException = specificException.getASuperType()
  )
}

// Main query to identify all unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue broaderException
where detectExceptOrderingIssue(earlierHandler, broaderException, 
                              laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()