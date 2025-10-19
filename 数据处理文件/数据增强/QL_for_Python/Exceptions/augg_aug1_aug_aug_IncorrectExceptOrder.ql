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

// Extracts the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an except block is unreachable due to handler ordering
predicate hasUnreachableHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                               ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIdx, int laterIdx, Try tryStmt |
    // Both handlers belong to the same try statement
    earlierHandler = tryStmt.getHandler(earlierIdx) and
    laterHandler = tryStmt.getHandler(laterIdx) and
    // Earlier handler appears before later handler in source order
    earlierIdx < laterIdx and
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
where hasUnreachableHandler(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()