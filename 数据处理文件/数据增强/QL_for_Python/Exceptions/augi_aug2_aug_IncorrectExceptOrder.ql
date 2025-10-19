/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
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
 * Maps an exception handler to its corresponding exception class.
 * @param handler - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled
 */
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Identifies incorrectly ordered exception handlers where a general exception
 * handler precedes a specific one that inherits from it.
 * @param precedingHandler - The exception handler that appears first
 * @param baseException - The general exception type handled by precedingHandler
 * @param followingHandler - The exception handler that appears later
 * @param derivedException - The specific exception type handled by followingHandler
 */
predicate exceptionOrderViolation(ExceptStmt precedingHandler, ClassValue baseException, 
                                 ExceptStmt followingHandler, ClassValue derivedException) {
  // Verify both handlers belong to the same try block
  exists(int firstPos, int secondPos, Try tryStmt |
    precedingHandler = tryStmt.getHandler(firstPos) and
    followingHandler = tryStmt.getHandler(secondPos) and
    firstPos < secondPos
  ) and
  // Retrieve and validate exception types
  baseException = getHandledExceptionClass(precedingHandler) and
  derivedException = getHandledExceptionClass(followingHandler) and
  // Confirm inheritance relationship
  baseException = derivedException.getASuperType()
}

// Main query identifying unreachable exception handlers
from ExceptStmt followingHandler, ClassValue derivedException, 
     ExceptStmt precedingHandler, ClassValue baseException
where exceptionOrderViolation(precedingHandler, baseException, 
                            followingHandler, derivedException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), precedingHandler, "except block", baseException, baseException.getName()