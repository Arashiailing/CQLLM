/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are shadowed by preceding broader handlers,
 *              making them unreachable as exceptions are caught by the earlier handler.
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

// Retrieves the exception type handled by an except statement
ClassValue getHandledExceptionType(ExceptStmt exceptStmt) { 
  exceptStmt.getType().pointsTo(result) 
}

// Determines unreachable handlers due to shadowing by broader exception handlers
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue broaderException, 
                                        ExceptStmt laterHandler, ClassValue narrowerException) {
  exists(int earlierIndex, int laterIndex, Try tryStmt |
    // Both handlers belong to the same try statement
    earlierHandler = tryStmt.getHandler(earlierIndex) and
    laterHandler = tryStmt.getHandler(laterIndex) and
    // Source order: earlier handler appears before later handler
    earlierIndex < laterIndex and
    // Retrieve exception types for both handlers
    broaderException = getHandledExceptionType(earlierHandler) and
    narrowerException = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of later handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Main query detecting all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue broaderException, 
     ExceptStmt laterHandler, ClassValue narrowerException
where hasUnreachableExceptionHandler(earlierHandler, broaderException, laterHandler, narrowerException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), earlierHandler, "except block", broaderException, broaderException.getName()