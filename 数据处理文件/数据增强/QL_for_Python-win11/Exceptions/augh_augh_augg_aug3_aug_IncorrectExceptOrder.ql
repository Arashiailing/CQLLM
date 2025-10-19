/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that cannot be reached due to improper ordering.
 *              When a broad exception type is caught before a specific subtype,
 *              the specific handler becomes unreachable because the broad handler
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

/**
 * Retrieves the exception class referenced by an exception handler.
 * @param handler - The exception statement to analyze
 * @return The class value representing the handled exception type
 */
ClassValue getExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Detects improper exception handler ordering where a broad exception
 * is caught before a specific one, making the specific handler unreachable.
 * @param precedingHandler - The exception handler that appears first in code
 * @param broaderException - The broad exception class handled earlier
 * @param followingHandler - The exception handler that appears later in code
 * @param narrowerException - The specific exception class handled later
 */
predicate detectExceptOrderingIssue(ExceptStmt precedingHandler, ClassValue broaderException, 
                                   ExceptStmt followingHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers must belong to the same try block
    precedingHandler = tryBlock.getHandler(earlierIndex) and
    followingHandler = tryBlock.getHandler(laterIndex) and
    // Verify sequence: preceding handler comes before following handler
    earlierIndex < laterIndex and
    // Extract exception types from both handlers
    broaderException = getExceptionClass(precedingHandler) and
    narrowerException = getExceptionClass(followingHandler) and
    // Confirm inheritance: broader exception is a superclass
    broaderException = narrowerException.getASuperType()
  )
}

// Main query to identify all unreachable exception handlers
from ExceptStmt followingHandler, ClassValue narrowerException, 
     ExceptStmt precedingHandler, ClassValue broaderException
where detectExceptOrderingIssue(precedingHandler, broaderException, 
                              followingHandler, narrowerException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), precedingHandler, "except block", broaderException, broaderException.getName()