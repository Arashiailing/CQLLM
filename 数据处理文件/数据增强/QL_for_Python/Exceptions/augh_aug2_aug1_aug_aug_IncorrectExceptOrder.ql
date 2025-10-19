/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable due to handler ordering.
 *              When a broader exception handler appears before a narrower one in the same
 *              try-except block, the broader handler intercepts all exceptions first.
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
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to ordering
predicate hasUnreachableHandler(ExceptStmt primaryHandler, ClassValue baseException, 
                              ExceptStmt secondaryHandler, ClassValue derivedException) {
  exists(int primaryIdx, int secondaryIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    primaryHandler = tryBlock.getHandler(primaryIdx) and
    secondaryHandler = tryBlock.getHandler(secondaryIdx) and
    // Primary handler appears before secondary handler in source code
    primaryIdx < secondaryIdx and
    // Retrieve exception types for both handlers
    baseException = getHandledExceptionClass(primaryHandler) and
    derivedException = getHandledExceptionClass(secondaryHandler) and
    // Primary handler catches a superclass of secondary handler's exception
    baseException = derivedException.getASuperType()
  )
}

// Locates all unreachable exception handlers
from ExceptStmt primaryHandler, ClassValue baseException, 
     ExceptStmt secondaryHandler, ClassValue derivedException
where hasUnreachableHandler(primaryHandler, baseException, secondaryHandler, derivedException)
select secondaryHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), primaryHandler, "except block", baseException, baseException.getName()