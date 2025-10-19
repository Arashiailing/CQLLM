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

// Retrieves the exception type handled by the given except block
ClassValue getHandledExceptionType(ExceptStmt exceptBlock) { 
  exceptBlock.getType().pointsTo(result) 
}

// Determines if a later except block is unreachable because an earlier except block handles a more general exception type
predicate hasUnreachableExceptionHandler(ExceptStmt earlierHandler, ClassValue generalExceptionType, 
                                        ExceptStmt laterHandler, ClassValue specificExceptionType) {
  exists(int earlierIndex, int laterIndex, Try tryStatement |
    // Both handlers belong to the same try statement
    earlierHandler = tryStatement.getHandler(earlierIndex) and
    laterHandler = tryStatement.getHandler(laterIndex) and
    // Earlier handler appears before the later one
    earlierIndex < laterIndex and
    // Retrieve exception types for both handlers
    generalExceptionType = getHandledExceptionType(earlierHandler) and
    specificExceptionType = getHandledExceptionType(laterHandler) and
    // Earlier handler catches a superclass of the later handler's exception
    generalExceptionType = specificExceptionType.getASuperType()
  )
}

// Identify unreachable except blocks by analyzing handler precedence
from ExceptStmt earlierHandler, ClassValue generalExceptionType, 
     ExceptStmt laterHandler, ClassValue specificExceptionType
where hasUnreachableExceptionHandler(earlierHandler, generalExceptionType, laterHandler, specificExceptionType)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), earlierHandler, "except block", generalExceptionType, generalExceptionType.getName()