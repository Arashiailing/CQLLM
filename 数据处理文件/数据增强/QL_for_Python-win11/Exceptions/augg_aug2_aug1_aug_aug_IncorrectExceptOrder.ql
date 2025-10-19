/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that can never execute due to earlier broader handlers
 *              in the same try-except block that intercept all exceptions first.
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

// Retrieves the exception class handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an except handler is unreachable due to handler precedence
predicate hasUnreachableHandler(ExceptStmt priorHandler, ClassValue generalException, 
                              ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int priorIndex, int subsequentIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    priorHandler = tryBlock.getHandler(priorIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Prior handler appears before subsequent handler in source code
    priorIndex < subsequentIndex and
    // Retrieve exception types for both handlers
    generalException = getHandledExceptionType(priorHandler) and
    specificException = getHandledExceptionType(subsequentHandler) and
    // Prior handler catches a superclass of subsequent handler's exception
    generalException = specificException.getASuperType()
  )
}

// Locates all unreachable exception handlers
from ExceptStmt priorHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where hasUnreachableHandler(priorHandler, generalException, subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), priorHandler, "except block", generalException, generalException.getName()