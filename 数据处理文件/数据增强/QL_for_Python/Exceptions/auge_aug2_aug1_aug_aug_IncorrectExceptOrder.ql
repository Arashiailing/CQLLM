/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are never executed because a more general
 *              exception handler precedes them in the same try-except structure, catching
 *              all exceptions before the more specific handler is reached.
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

// Retrieves the exception class that is handled by a given except clause
ClassValue extractExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to the ordering of handlers
predicate isHandlerUnreachable(ExceptStmt precedingHandler, ClassValue generalExceptionType, 
                              ExceptStmt subsequentHandler, ClassValue specificExceptionType) {
  exists(int precedingIndex, int subsequentIndex, Try tryStatement |
    // Both handlers are associated with the same try statement
    precedingHandler = tryStatement.getHandler(precedingIndex) and
    subsequentHandler = tryStatement.getHandler(subsequentIndex) and
    // The preceding handler appears before the subsequent handler in the source code
    precedingIndex < subsequentIndex and
    // Extract the exception types for both handlers
    generalExceptionType = extractExceptionClass(precedingHandler) and
    specificExceptionType = extractExceptionClass(subsequentHandler) and
    // The preceding handler catches a superclass of the subsequent handler's exception
    generalExceptionType = specificExceptionType.getASuperType()
  )
}

// Locates all unreachable exception handlers in the codebase
from ExceptStmt precedingHandler, ClassValue generalExceptionType, 
     ExceptStmt subsequentHandler, ClassValue specificExceptionType
where isHandlerUnreachable(precedingHandler, generalExceptionType, subsequentHandler, specificExceptionType)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), precedingHandler, "except block", generalExceptionType, generalExceptionType.getName()