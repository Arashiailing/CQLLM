/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute due to improper ordering
 *              where a general exception handler precedes a specific one.
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
 * Retrieves the exception class associated with an exception handler.
 * @param exceptHandler - The exception statement to analyze
 * @return The class value representing the exception type
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptHandler) { 
  exceptHandler.getType().pointsTo(result) 
}

// Main query identifying unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue broadException
where exists(int earlierIndex, int laterIndex, Try tryBlock |
  // Both handlers must belong to the same try statement
  earlierHandler = tryBlock.getHandler(earlierIndex) and
  laterHandler = tryBlock.getHandler(laterIndex) and
  // Verify handlers appear in correct sequence
  earlierIndex < laterIndex and
  // Retrieve exception types for both handlers
  broadException = getHandledExceptionClass(earlierHandler) and
  specificException = getHandledExceptionClass(laterHandler) and
  // Check inheritance: broad exception is a superclass
  broadException = specificException.getASuperType()
)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", broadException, broadException.getName()