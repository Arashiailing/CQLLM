/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable due to handler ordering,
 *              where a broader exception handler earlier in the try-except block
 *              intercepts all exceptions before narrower handlers can execute.
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

// Extracts the exception class handled by an except clause
ClassValue extractHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Determines if an exception handler is unreachable due to preceding broader handler
predicate isHandlerUnreachable(ExceptStmt precedingHandler, ClassValue generalException, 
                              ExceptStmt subsequentHandler, ClassValue specificException) {
  exists(int precedingIdx, int subsequentIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    precedingHandler = tryBlock.getHandler(precedingIdx) and
    subsequentHandler = tryBlock.getHandler(subsequentIdx) and
    // Preceding handler appears before subsequent handler in source
    precedingIdx < subsequentIdx and
    // Extract exception types for both handlers
    generalException = extractHandledExceptionType(precedingHandler) and
    specificException = extractHandledExceptionType(subsequentHandler) and
    // Preceding handler catches a superclass of subsequent handler's exception
    generalException = specificException.getASuperType()
  )
}

// Identifies all unreachable exception handlers
from ExceptStmt precedingHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where isHandlerUnreachable(precedingHandler, generalException, subsequentHandler, specificException)
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()