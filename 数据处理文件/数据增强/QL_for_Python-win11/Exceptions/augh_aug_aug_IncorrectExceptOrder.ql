/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that become unreachable due to being positioned 
 *              after a more general handler that catches the same exception type first.
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

// Retrieves the exception type handled by an exception handler
ClassValue getHandledExceptionType(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to preceding handler precedence
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue broaderType, 
                                        ExceptStmt laterHandler, ClassValue narrowerType) {
  exists(int earlierIndex, int laterIndex, Try tryStmt |
    // Both handlers belong to the same try statement
    earlierHandler = tryStmt.getHandler(earlierIndex) and
    laterHandler = tryStmt.getHandler(laterIndex) and
    // Earlier handler appears before later handler
    earlierIndex < laterIndex and
    // Retrieve exception types for both handlers
    broaderType = getHandledExceptionType(earlierHandler) and
    narrowerType = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of later handler's exception
    broaderType = narrowerType.getASuperType()
  )
}

// Identify unreachable exception handlers and their unreachable exception types
from ExceptStmt earlierHandler, ClassValue broaderType, 
     ExceptStmt laterHandler, ClassValue narrowerType
where hasUnreachableExceptionHandler(earlierHandler, broaderType, laterHandler, narrowerType)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerType, narrowerType.getName(), earlierHandler, "except block", broaderType, broaderType.getName()