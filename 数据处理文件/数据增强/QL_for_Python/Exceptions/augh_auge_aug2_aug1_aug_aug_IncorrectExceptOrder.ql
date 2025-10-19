/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute because a broader exception handler
 *              appears earlier in the same try-except structure, intercepting all exceptions
 *              before the more specific handler is reached.
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

// Determines if an exception handler is shadowed by a preceding broader handler
predicate isExceptHandlerShadowed(ExceptStmt precedingExcept, ClassValue broaderExType, 
                                 ExceptStmt shadowedExcept, ClassValue narrowerExType) {
  exists(int precedingIdx, int shadowedIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    precedingExcept = tryBlock.getHandler(precedingIdx) and
    shadowedExcept = tryBlock.getHandler(shadowedIdx) and
    // Preceding handler appears before the shadowed one
    precedingIdx < shadowedIdx and
    // Retrieve exception types for both handlers
    broaderExType = getHandledExceptionClass(precedingExcept) and
    narrowerExType = getHandledExceptionClass(shadowedExcept) and
    // Preceding handler catches a superclass of the shadowed handler's exception
    broaderExType = narrowerExType.getASuperType()
  )
}

// Identifies all shadowed exception handlers in the codebase
from ExceptStmt precedingExcept, ClassValue broaderExType, 
     ExceptStmt shadowedExcept, ClassValue narrowerExType
where isExceptHandlerShadowed(precedingExcept, broaderExType, shadowedExcept, narrowerExType)
select shadowedExcept,
  "Except block for $@ is unreachable; the broader $@ for $@ will always intercept exceptions first.",
  narrowerExType, narrowerExType.getName(), precedingExcept, "except block", broaderExType, broaderExType.getName()