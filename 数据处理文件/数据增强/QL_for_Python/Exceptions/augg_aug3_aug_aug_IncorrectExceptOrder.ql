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

// Retrieves the exception type handled by an except statement
ClassValue getHandledExceptionType(ExceptStmt exceptStmt) { 
  exceptStmt.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to handler ordering
predicate hasUnreachableExceptionHandler(ExceptStmt preceedingHandler, ClassValue broaderExceptionType, 
                                        ExceptStmt subsequentHandler, ClassValue narrowerExceptionType) {
  exists(Try tryStatement, int preceedingIndex, int subsequentIndex |
    // Both handlers belong to the same try statement
    preceedingHandler = tryStatement.getHandler(preceedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    // Preceeding handler appears before subsequent handler
    preceedingIndex < subsequentIndex and
    // Retrieve handled exception types
    broaderExceptionType = getHandledExceptionType(preceedingHandler) and
    narrowerExceptionType = getHandledExceptionType(subsequentHandler) and
    // Preceeding handler catches a superclass of the subsequent handler's exception
    broaderExceptionType = narrowerExceptionType.getASuperType()
  )
}

// Identify unreachable exception handlers across all code
from ExceptStmt preceedingHandler, ClassValue broaderExceptionType, 
     ExceptStmt subsequentHandler, ClassValue narrowerExceptionType
// Verify handler ordering causes unreachability
where hasUnreachableExceptionHandler(preceedingHandler, broaderExceptionType, subsequentHandler, narrowerExceptionType)
// Generate alert for unreachable handler
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerExceptionType, narrowerExceptionType.getName(), preceedingHandler, "except block", broaderExceptionType, broaderExceptionType.getName()