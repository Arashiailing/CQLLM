/**
 * @name Unreachable 'except' block
 * @description Identifies situations where a specific exception handler is positioned after a general one,
 *              causing it to be unreachable because the general handler will always intercept the exception first.
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

// Determines if an exception handler is unreachable due to handler ordering
predicate hasUnreachableHandler(ExceptStmt precedingHandler, ClassValue superTypeException, 
                                ExceptStmt subsequentHandler, ClassValue subTypeException) {
  exists(int precedingIndex, int subsequentIndex, Try tryBlock |
    // Both handlers belong to the same try statement
    precedingHandler = tryBlock.getHandler(precedingIndex) and
    subsequentHandler = tryBlock.getHandler(subsequentIndex) and
    // Preceding handler appears before subsequent handler in source code
    precedingIndex < subsequentIndex and
    // Extract exception types for both handlers
    superTypeException = getHandledExceptionType(precedingHandler) and
    subTypeException = getHandledExceptionType(subsequentHandler) and
    // Preceding handler catches a superclass of subsequent handler's exception
    superTypeException = subTypeException.getASuperType()
  )
}

// Main query identifying unreachable exception handlers
from ExceptStmt precedingHandler, ClassValue superTypeException, 
     ExceptStmt subsequentHandler, ClassValue subTypeException
// Check if handler ordering creates unreachable exception block
where hasUnreachableHandler(precedingHandler, superTypeException, subsequentHandler, subTypeException)
// Generate result with unreachable block and warning message
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  subTypeException, subTypeException.getName(), precedingHandler, "except block", superTypeException, superTypeException.getName()