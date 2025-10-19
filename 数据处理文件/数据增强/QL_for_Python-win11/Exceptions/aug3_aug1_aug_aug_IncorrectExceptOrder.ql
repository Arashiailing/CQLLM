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
predicate hasUnreachableHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                               ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    // The earlier handler appears before the later handler in source code
    earlierIndex < laterIndex and
    // Extract the exception types for both handlers
    broaderException = getHandledExceptionType(earlierHandler) and
    narrowerException = getHandledExceptionType(laterHandler) and
    // The earlier handler catches a superclass of the exception caught by the later handler
    broaderException = narrowerException.getASuperType()
  )
}

// Main query that identifies all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
// Verify if the handler ordering creates an unreachable exception block
where hasUnreachableHandler(earlierHandler, broaderException, laterHandler, narrowerException)
// Generate the result with the unreachable block and appropriate warning message
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()