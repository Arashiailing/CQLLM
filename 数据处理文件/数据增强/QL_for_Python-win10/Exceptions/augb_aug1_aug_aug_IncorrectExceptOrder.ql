/**
 * @name Unreachable 'except' block
 * @description Identifies situations where a specific exception handler is positioned after a general one,
 *              causing it to be unreachable because the general handler will always intercept the exception first.
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

// Helper function to extract the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Predicate that determines if an except block is unreachable due to handler ordering
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                                        ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try enclosingTry |
    // Both handlers belong to the same try statement
    earlierHandler = enclosingTry.getHandler(earlierIndex) and
    laterHandler = enclosingTry.getHandler(laterIndex) and
    // Source order: earlier handler appears before later handler
    earlierIndex < laterIndex and
    // Extract exception types for both handlers
    broaderException = getHandledExceptionType(earlierHandler) and
    narrowerException = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Main query identifying all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
// Check if handler ordering creates unreachable exception block
where hasUnreachableExceptionHandler(earlierHandler, broaderException, laterHandler, narrowerException)
// Generate result with unreachable block and warning message
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()