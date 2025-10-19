/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute due to improper ordering
 *              where general exceptions are caught before specific exceptions that inherit from them.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @external/cwe/cwe-561
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unreachable-except
 */

import python

/**
 * Maps an exception handler to its associated exception class.
 * @param handlerStmt - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by the block
 */
ClassValue getExceptionClass(ExceptStmt handlerStmt) { 
  handlerStmt.getType().pointsTo(result) 
}

/**
 * Identifies incorrectly ordered exception handlers where a general exception
 * precedes a specific exception that inherits from it.
 * @param precedingHandler - Earlier exception handler in the code
 * @param broadException - General exception type handled by precedingHandler
 * @param followingHandler - Later exception handler in the code
 * @param narrowException - Specific exception type handled by followingHandler
 */
predicate hasIncorrectExceptOrder(ExceptStmt precedingHandler, ClassValue broadException, 
                                 ExceptStmt followingHandler, ClassValue narrowException) {
  exists(int precedingIdx, int followingIdx, Try tryContext |
    // Verify handlers belong to same try block with proper sequence
    precedingHandler = tryContext.getHandler(precedingIdx) and
    followingHandler = tryContext.getHandler(followingIdx) and
    precedingIdx < followingIdx
  ) and
  // Retrieve exception types for both handlers
  broadException = getExceptionClass(precedingHandler) and
  narrowException = getExceptionClass(followingHandler) and
  // Confirm inheritance relationship (broad is superclass of narrow)
  broadException = narrowException.getASuperType()
}

// Main query detecting unreachable exception handlers
from ExceptStmt followingHandler, ClassValue narrowException, 
     ExceptStmt precedingHandler, ClassValue broadException
where hasIncorrectExceptOrder(precedingHandler, broadException, 
                             followingHandler, narrowException)
select followingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  narrowException, narrowException.getName(), precedingHandler, "except block", broadException, broadException.getName()