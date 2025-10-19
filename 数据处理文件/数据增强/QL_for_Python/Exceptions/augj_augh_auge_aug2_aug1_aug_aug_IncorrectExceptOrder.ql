/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable because a broader exception handler
 *              appears earlier in the same try-except structure, catching all exceptions before
 *              more specific handlers can be reached.
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
ClassValue extractHandledExceptionClass(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Determines if a specific exception handler is shadowed by a preceding broader handler
predicate isExceptionHandlerShadowed(ExceptStmt priorExcept, ClassValue broaderExceptionType, 
                                    ExceptStmt shadowedException, ClassValue narrowerExceptionType) {
  exists(int priorIndex, int shadowedIndex, Try tryStatement |
    // Both handlers belong to the same try statement
    priorExcept = tryStatement.getHandler(priorIndex) and
    shadowedException = tryStatement.getHandler(shadowedIndex) and
    // Preceding handler appears before the shadowed one
    priorIndex < shadowedIndex and
    // Retrieve exception types for both handlers
    broaderExceptionType = extractHandledExceptionClass(priorExcept) and
    narrowerExceptionType = extractHandledExceptionClass(shadowedException) and
    // Preceding handler catches a superclass of the shadowed handler's exception
    broaderExceptionType = narrowerExceptionType.getASuperType()
  )
}

// Identifies all shadowed exception handlers in the codebase
from ExceptStmt priorExcept, ClassValue broaderExceptionType, 
     ExceptStmt shadowedException, ClassValue narrowerExceptionType
where isExceptionHandlerShadowed(priorExcept, broaderExceptionType, shadowedException, narrowerExceptionType)
select shadowedException,
  "Except block for $@ is unreachable; the broader $@ for $@ will always intercept exceptions first.",
  narrowerExceptionType, narrowerExceptionType.getName(), priorExcept, "except block", broaderExceptionType, broaderExceptionType.getName()