/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that are positioned after more general ones,
 *              making them unreachable as the general handlers will catch exceptions first.
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

// Extract the exception type handled by an exception handler
ClassValue getExceptionTypeHandled(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determine if an exception handler is unreachable due to its position
// This occurs when a handler for a specific exception is placed after a handler for a more general exception
predicate isUnreachableDueToOrder(ExceptStmt precedingHandler, ClassValue broaderExceptionType, 
                                  ExceptStmt subsequentHandler, ClassValue narrowerExceptionType) {
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // Both handlers must belong to the same try statement
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    // The preceding handler must come before the subsequent one
    precedingIndex < subsequentIndex and
    // Get the exception types handled by each handler
    broaderExceptionType = getExceptionTypeHandled(precedingHandler) and
    narrowerExceptionType = getExceptionTypeHandled(subsequentHandler) and
    // The preceding handler handles a superclass of the exception handled by the subsequent handler
    broaderExceptionType = narrowerExceptionType.getASuperType()
  )
}

// Find all unreachable exception handlers
from ExceptStmt precedingHandler, ClassValue broaderExceptionType, 
     ExceptStmt subsequentHandler, ClassValue narrowerExceptionType
// Apply the predicate to check if there's an ordering issue
where isUnreachableDueToOrder(precedingHandler, broaderExceptionType, subsequentHandler, narrowerExceptionType)
// Select the unreachable handler and generate a detailed warning message
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowerExceptionType, narrowerExceptionType.getName(), precedingHandler, "except block", broaderExceptionType, broaderExceptionType.getName()