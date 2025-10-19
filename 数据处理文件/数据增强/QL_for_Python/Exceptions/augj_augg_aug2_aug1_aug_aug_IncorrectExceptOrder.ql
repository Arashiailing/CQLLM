/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that can never execute due to earlier broader handlers
 *              in the same try-except block that intercept all exceptions first.
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

// Retrieves the exception class handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an except handler is unreachable due to handler precedence
predicate hasUnreachableHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                              ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    earlierHandler = tryBlock.getHandler(earlierIndex) and
    laterHandler = tryBlock.getHandler(laterIndex) and
    // Earlier handler appears before later handler in source code
    earlierIndex < laterIndex and
    // Retrieve exception types for both handlers
    broaderException = getHandledExceptionType(earlierHandler) and
    narrowerException = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Locates all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where hasUnreachableHandler(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()