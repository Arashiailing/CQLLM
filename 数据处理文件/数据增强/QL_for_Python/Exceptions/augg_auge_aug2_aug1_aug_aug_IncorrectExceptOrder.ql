/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are never executed because a more general
 *              exception handler precedes them in the same try-except structure, catching
 *              all exceptions before the more specific handler is reached.
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

// Extracts the exception class handled by a given except clause
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an exception handler is shadowed by a preceding broader handler
predicate isHandlerShadowed(ExceptStmt earlierHandler, ClassValue broaderException, 
                            ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    // Source code order: earlier handler appears first
    earlierIndex < laterIndex and
    // Extract exception types for both handlers
    broaderException = getHandledExceptionClass(earlierHandler) and
    narrowerException = getHandledExceptionClass(laterHandler) and
    // Earlier handler catches a superclass of the later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Find all unreachable exception handlers due to handler ordering
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where isHandlerShadowed(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()