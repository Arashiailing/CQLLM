/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute because a broader exception handler
 *              appears earlier in the same try-except block, intercepting all exceptions first.
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

// Extracts the exception class handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Checks if an except handler is unreachable due to handler ordering
predicate hasUnreachableHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                              ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIdx, int laterIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    earlierHandler = tryBlock.getHandler(earlierIdx) and
    laterHandler = tryBlock.getHandler(laterIdx) and
    // Earlier handler appears before later handler in source
    earlierIdx < laterIdx and
    // Get exception types for both handlers
    broaderException = getHandledExceptionType(earlierHandler) and
    narrowerException = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Identifies all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where hasUnreachableHandler(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()