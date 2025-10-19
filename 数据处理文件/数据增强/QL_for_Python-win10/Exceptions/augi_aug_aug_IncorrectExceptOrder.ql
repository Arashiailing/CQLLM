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

// Extracts the exception type that an except statement handles
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if a later exception handler is unreachable because an earlier handler
// catches a more general exception type that would be triggered first
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue generalExceptionType, 
                                        ExceptStmt laterHandler, ClassValue specificExceptionType) {
  exists(int earlierIndex, int laterIndex, Try tryStatement |
    // Both handlers are associated with the same try statement
    earlierHandler = tryStatement.getHandler(earlierIndex) and
    laterHandler = tryStatement.getHandler(laterIndex) and
    // The earlier handler appears before the later one in the code
    earlierIndex < laterIndex and
    // Retrieve the exception types handled by each handler
    generalExceptionType = getHandledExceptionType(earlierHandler) and
    specificExceptionType = getHandledExceptionType(laterHandler) and
    // The earlier handler catches a superclass of the exception caught by the later handler
    generalExceptionType = specificExceptionType.getASuperType()
  )
}

// Identify all unreachable exception handlers
from ExceptStmt earlierHandler, ClassValue generalExceptionType, 
     ExceptStmt laterHandler, ClassValue specificExceptionType
// Verify if there's an ordering problem that makes the later handler unreachable
where hasUnreachableExceptionHandler(earlierHandler, generalExceptionType, laterHandler, specificExceptionType)
// Select the unreachable handler and generate an appropriate warning message
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), earlierHandler, "except block", generalExceptionType, generalExceptionType.getName()