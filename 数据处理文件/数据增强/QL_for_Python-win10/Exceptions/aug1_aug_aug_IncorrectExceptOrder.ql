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

// Helper function to extract the exception type handled by an except clause
ClassValue extractHandledExceptionType(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

// Predicate that determines if an except block is unreachable due to handler ordering
predicate containsUnreachableHandler(ExceptStmt priorHandler, ClassValue generalException, 
                                    ExceptStmt followingHandler, ClassValue specificException) {
  exists(int priorIndex, int followingIndex, Try tryBlock |
    // Both handlers are part of the same try statement
    priorHandler = tryBlock.getHandler(priorIndex) and
    followingHandler = tryBlock.getHandler(followingIndex) and
    // The prior handler appears before the following handler in source code
    priorIndex < followingIndex and
    // Extract the exception types for both handlers
    generalException = extractHandledExceptionType(priorHandler) and
    specificException = extractHandledExceptionType(followingHandler) and
    // The prior handler catches a superclass of the exception caught by the following handler
    generalException = specificException.getASuperType()
  )
}

// Main query that identifies all unreachable exception handlers
from ExceptStmt priorHandler, ClassValue generalException, 
     ExceptStmt followingHandler, ClassValue specificException
// Verify if the handler ordering creates an unreachable exception block
where containsUnreachableHandler(priorHandler, generalException, followingHandler, specificException)
// Generate the result with the unreachable block and appropriate warning message
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), priorHandler, "except block", generalException, generalException.getName()