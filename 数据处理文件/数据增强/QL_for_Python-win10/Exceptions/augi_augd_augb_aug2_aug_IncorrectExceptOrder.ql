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
 * Extracts the exception class referenced by an exception handler.
 * @param exceptClause - The exception handler to analyze
 * @return - The ClassValue representing the exception type handled by this clause
 */
ClassValue extractExceptionClass(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

/**
 * Identifies pairs of exception handlers where a base exception is caught
 * before a derived exception in the same try block, making the latter unreachable.
 * @param precedingHandler - The exception handler that appears first
 * @param baseException - The general exception type handled by the preceding handler
 * @param followingHandler - The exception handler that appears later
 * @param derivedException - The specific exception type handled by the following handler
 */
predicate findIncorrectExceptOrdering(ExceptStmt precedingHandler, ClassValue baseException, 
                                     ExceptStmt followingHandler, ClassValue derivedException) {
  // Verify both handlers are in the same try block with correct ordering
  exists(int precedingIndex, int followingIndex, Try tryBlock |
    precedingHandler = tryBlock.getHandler(precedingIndex) and
    followingHandler = tryBlock.getHandler(followingIndex) and
    precedingIndex < followingIndex
  ) and
  // Extract exception types for both handlers
  baseException = extractExceptionClass(precedingHandler) and
  derivedException = extractExceptionClass(followingHandler) and
  // Confirm inheritance relationship (baseException is a superclass of derivedException)
  baseException = derivedException.getASuperType()
}

// Main query that identifies unreachable exception handlers due to incorrect ordering
from ExceptStmt followingHandler, ClassValue derivedException, 
     ExceptStmt precedingHandler, ClassValue baseException
where findIncorrectExceptOrdering(precedingHandler, baseException, 
                                followingHandler, derivedException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), precedingHandler, "except block", baseException, baseException.getName()