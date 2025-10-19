/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that are shadowed by preceding broader handlers,
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

// Extracts the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Identifies unreachable handlers due to shadowing by broader exception handlers
predicate hasUnreachableExceptionHandler(ExceptStmt priorHandler, ClassValue generalException, 
                                        ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int priorIndex, int subsequentIndex, Try enclosingTry |
    // Both handlers belong to the same try statement
    priorHandler = enclosingTry.getHandler(priorIndex) and
    subsequentHandler = enclosingTry.getHandler(subsequentIndex) and
    // Source order: prior handler appears before subsequent handler
    priorIndex < subsequentIndex and
    // Extract exception types for both handlers
    generalException = getHandledExceptionType(priorHandler) and
    specificException = getHandledExceptionType(subsequentHandler) and
    // Prior handler catches a superclass of subsequent handler's exception
    generalException = specificException.getASuperType()
  )
}

// Main query detecting all unreachable exception handlers
from ExceptStmt priorHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where hasUnreachableExceptionHandler(priorHandler, generalException, subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), priorHandler, "except block", generalException, generalException.getName()