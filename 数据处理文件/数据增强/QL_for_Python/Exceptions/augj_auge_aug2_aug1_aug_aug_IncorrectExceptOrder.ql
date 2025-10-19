/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute because a broader
 *              exception handler appears earlier in the same try-except structure,
 *              catching all exceptions before the more specific handler is reached.
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

// Extracts the exception class handled by a given except clause
ClassValue getHandledExceptionClass(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to handler ordering
predicate isUnreachableHandler(ExceptStmt earlierHandler, ClassValue superType, 
                              ExceptStmt laterHandler, ClassValue subType) {
  exists(int earlierIdx, int laterIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    earlierHandler = tryBlock.getHandler(earlierIdx) and
    laterHandler = tryBlock.getHandler(laterIdx) and
    // Earlier handler appears before later handler in source code
    earlierIdx < laterIdx and
    // Extract exception types for both handlers
    superType = getHandledExceptionClass(earlierHandler) and
    subType = getHandledExceptionClass(laterHandler) and
    // Earlier handler catches superclass of later handler's exception
    superType = subType.getASuperType()
  )
}

// Identifies all unreachable exception handlers in the codebase
from ExceptStmt earlierHandler, ClassValue superType, 
     ExceptStmt laterHandler, ClassValue subType
where isUnreachableHandler(earlierHandler, superType, laterHandler, subType)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subType, subType.getName(), earlierHandler, "except block", superType, superType.getName()