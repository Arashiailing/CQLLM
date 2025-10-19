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
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue generalExceptionType, 
                                        ExceptStmt laterHandler, ClassValue specificExceptionType) {
  exists(Try tryStatement, int earlierIndex, int laterIndex |
    // Both handlers belong to the same try statement
    earlierHandler = tryStatement.getHandler(earlierIndex) and
    laterHandler = tryStatement.getHandler(laterIndex) and
    // Earlier handler appears before later handler
    earlierIndex < laterIndex and
    // Retrieve handled exception types
    generalExceptionType = getHandledExceptionType(earlierHandler) and
    specificExceptionType = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of the later handler's exception
    generalExceptionType = specificExceptionType.getASuperType()
  )
}

// Identify unreachable exception handlers across all code
from ExceptStmt earlierHandler, ClassValue generalExceptionType, 
     ExceptStmt laterHandler, ClassValue specificExceptionType
// Verify handler ordering causes unreachability
where hasUnreachableExceptionHandler(earlierHandler, generalExceptionType, laterHandler, specificExceptionType)
// Generate alert for unreachable handler
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), earlierHandler, "except block", generalExceptionType, generalExceptionType.getName()