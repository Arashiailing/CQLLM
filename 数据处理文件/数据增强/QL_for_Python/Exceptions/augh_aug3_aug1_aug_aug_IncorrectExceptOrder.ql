/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that become unreachable due to improper ordering,
 *              where a general exception handler precedes a specific one, preventing
 *              the specific handler from ever being executed.
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

// Extract the exception type handled by an except clause
ClassValue getHandledExceptionType(ExceptStmt exceptClause) { 
  exceptClause.getType().pointsTo(result) 
}

// Check if an except handler is shadowed by a preceding broader handler
predicate hasUnreachableHandler(ExceptStmt precedingHandler, ClassValue generalException, 
                               ExceptStmt followingHandler, ClassValue specificException) {
  exists(int precedingIdx, int followingIdx, Try tryBlock |
    // Both handlers belong to the same try statement
    precedingHandler = tryBlock.getHandler(precedingIdx) and
    followingHandler = tryBlock.getHandler(followingIdx) and
    // Source order: preceding handler appears first
    precedingIdx < followingIdx and
    // Get exception types for both handlers
    generalException = getHandledExceptionType(precedingHandler) and
    specificException = getHandledExceptionType(followingHandler) and
    // Preceding handler catches a superclass of the following handler's exception
    generalException = specificException.getASuperType()
  )
}

// Identify all unreachable exception handlers due to handler ordering
from ExceptStmt precedingHandler, ClassValue generalException, 
     ExceptStmt followingHandler, ClassValue specificException
where hasUnreachableHandler(precedingHandler, generalException, followingHandler, specificException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()