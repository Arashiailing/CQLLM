/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that are never executed because a more general
 *              exception handler appears earlier in the same try-except structure, catching
 *              all exceptions before the more specific handler can be reached.
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

// Retrieves the exception class handled by a specified except clause
ClassValue getHandledExceptionClass(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Determines if a later exception handler is shadowed by an earlier broader handler
predicate isHandlerShadowed(ExceptStmt priorHandler, ClassValue generalException, 
                            ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int priorIndex, int subsequentIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    priorHandler = tryBlock.getHandler(priorIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Source code order: prior handler appears before subsequent handler
    priorIndex < subsequentIndex and
    // Extract exception types for both handlers
    generalException = getHandledExceptionClass(priorHandler) and
    specificException = getHandledExceptionClass(subsequentHandler) and
    // Prior handler catches a superclass of the subsequent handler's exception
    generalException = specificException.getASuperType()
  )
}

// Identify all unreachable exception handlers due to handler ordering
from ExceptStmt priorHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where isHandlerShadowed(priorHandler, generalException, subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), priorHandler, "except block", generalException, generalException.getName()