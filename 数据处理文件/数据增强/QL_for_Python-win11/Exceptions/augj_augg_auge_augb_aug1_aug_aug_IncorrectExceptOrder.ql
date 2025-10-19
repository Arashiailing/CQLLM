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

// Extracts the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Detects shadowed exception handlers where a broader handler precedes a narrower one
predicate isShadowedExceptionHandler(ExceptStmt priorHandler, ClassValue generalException, 
                                     ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int priorIndex, int subsequentIndex, Try tryBlock |
    // Both handlers belong to the same try block
    priorHandler = tryBlock.getHandler(priorIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Source order: prior handler appears before subsequent handler
    priorIndex < subsequentIndex and
    // Retrieve exception types for both handlers
    generalException = getHandledExceptionType(priorHandler) and
    specificException = getHandledExceptionType(subsequentHandler) and
    // Prior handler catches a superclass of subsequent handler's exception
    generalException = specificException.getASuperType()
  )
}

// Main query identifying all unreachable exception handlers
from ExceptStmt priorHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where isShadowedExceptionHandler(priorHandler, generalException, subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), priorHandler, "except block", generalException, generalException.getName()