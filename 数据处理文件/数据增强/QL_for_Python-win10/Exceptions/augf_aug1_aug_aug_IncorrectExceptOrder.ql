/**
 * @name Unreachable 'except' block
 * @description Detects unreachable exception handlers caused by improper ordering,
 *              where a general exception handler precedes a specific one,
 *              making the specific handler unreachable.
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

// Retrieves the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to handler ordering
predicate isUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue baseException, 
                                      ExceptStmt laterHandler, ClassValue derivedException) {
  exists(int earlierIndex, int laterIndex, Try tryStmt |
    // Both handlers belong to the same try statement
    earlierHandler = tryStmt.getHandler(earlierIndex) and
    laterHandler = tryStmt.getHandler(laterIndex) and
    // Source code position: earlier handler comes first
    earlierIndex < laterIndex and
    // Extract exception types for both handlers
    baseException = getHandledExceptionType(earlierHandler) and
    derivedException = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of the later handler's exception
    baseException = derivedException.getASuperType()
  )
}

// Main query identifying all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue baseException, 
     ExceptStmt laterHandler, ClassValue derivedException
// Check if handler ordering creates unreachable exception block
where isUnreachableExceptionHandler(earlierHandler, baseException, laterHandler, derivedException)
// Generate result with unreachable block and warning message
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), earlierHandler, "except block", baseException, baseException.getName()