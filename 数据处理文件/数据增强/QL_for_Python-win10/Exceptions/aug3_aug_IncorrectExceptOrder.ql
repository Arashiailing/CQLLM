/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
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
 * Extracts the exception class associated with an exception handler.
 * @param handler - The exception statement to analyze
 * @return The class value representing the exception type
 */
ClassValue fetchExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Identifies incorrect ordering of exception handlers where a general exception
 * handler precedes a specific one, making the specific handler unreachable.
 * @param precedingHandler - The earlier exception handler in the code
 * @param generalException - The broader exception class handled first
 * @param subsequentHandler - The later exception handler in the code
 * @param narrowException - The more specific exception class handled later
 */
predicate checkExceptOrderIssue(ExceptStmt precedingHandler, ClassValue generalException, 
                               ExceptStmt subsequentHandler, ClassValue narrowException) {
  exists(int precedingIndex, int subsequentIndex, Try tryStmt |
    // Both handlers must belong to the same try statement
    precedingHandler = tryStmt.getHandler(precedingIndex) and
    subsequentHandler = tryStmt.getHandler(subsequentIndex) and
    // Verify the handlers appear in the correct sequence
    precedingIndex < subsequentIndex and
    // Retrieve the exception types for both handlers
    generalException = fetchExceptionClass(precedingHandler) and
    narrowException = fetchExceptionClass(subsequentHandler) and
    // Check inheritance relationship: general exception is a superclass
    generalException = narrowException.getASuperType()
  )
}

// Main query to detect all unreachable exception handlers
from ExceptStmt subsequentHandler, ClassValue narrowException, 
     ExceptStmt precedingHandler, ClassValue generalException
where checkExceptOrderIssue(precedingHandler, generalException, 
                           subsequentHandler, narrowException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowException, narrowException.getName(), precedingHandler, "except block", generalException, generalException.getName()