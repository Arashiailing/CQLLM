/**
 * @name Unreachable 'except' block
 * @description Identifies exception handling blocks that can never be executed because they are
 *              shadowed by preceding handlers that catch broader exception types. Once an
 *              exception is caught by a handler, subsequent handlers are skipped.
 * @kind problem
 * @tags reliability
 *       maintainability
 *              external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

// Retrieves the specific exception type that an except clause is designed to handle
ClassValue extractExceptionType(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Determines if an exception handler is made unreachable by a preceding handler
// that catches a superclass of the exception type
predicate isHandlerShadowedByPreceding(ExceptStmt precedingHandler, ClassValue broaderException, 
                                       ExceptStmt shadowedHandler, ClassValue narrowerException) {
  exists(int precedingIndex, int shadowedIndex, Try tryStatement |
    // Both handlers are part of the same try-except statement
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    shadowedHandler = tryStatement.getHandler(shadowedIndex) and
    // The shadowed handler appears after the preceding handler in source code
    precedingIndex < shadowedIndex and
    // Extract the exception types handled by each handler
    broaderException = extractExceptionType(precedingHandler) and
    narrowerException = extractExceptionType(shadowedHandler) and
    // The preceding handler catches a superclass of the shadowed handler's exception
    broaderException = narrowerException.getASuperType()
  )
}

// Main query that identifies all unreachable exception handlers due to shadowing
from ExceptStmt precedingHandler, ClassValue broaderException, 
     ExceptStmt shadowedHandler, ClassValue narrowerException
where isHandlerShadowedByPreceding(precedingHandler, broaderException, shadowedHandler, narrowerException)
select shadowedHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerException, narrowerException.getName(), precedingHandler, "except block", broaderException, broaderException.getName()