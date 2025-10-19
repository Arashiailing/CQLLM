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
 * Retrieves the exception type associated with an exception handler.
 * @param handler - The exception statement to analyze
 * @return The class value representing the handled exception type
 */
ClassValue getExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Main query to detect unreachable exception handlers
from ExceptStmt subsequentHandler, ClassValue specificException, 
     ExceptStmt precedingHandler, ClassValue broaderException
where 
  exists(int precedingIndex, int subsequentIndex, Try tryStmt |
    // Both handlers must belong to the same try statement
    precedingHandler = tryStmt.getHandler(precedingIndex) and
    subsequentHandler = tryStmt.getHandler(subsequentIndex) and
    // Verify handlers appear in correct sequence
    precedingIndex < subsequentIndex and
    // Retrieve exception types for both handlers
    broaderException = getExceptionClass(precedingHandler) and
    specificException = getExceptionClass(subsequentHandler) and
    // Check inheritance: broader exception is superclass of specific exception
    broaderException = specificException.getASuperType()
  )
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", broaderException, broaderException.getName()