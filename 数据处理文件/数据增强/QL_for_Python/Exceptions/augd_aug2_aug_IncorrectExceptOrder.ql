/**
 * @name Unreachable 'except' block
 * @description Handling general exceptions before specific exceptions means that the specific
 *              handlers are never executed.
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
 * Maps an exception handler to its handled exception class.
 * @param handler - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by the handler
 */
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Identifies incorrectly ordered exception handlers where a general exception
 * handler precedes a specific one that inherits from it.
 * @param generalHandler - The exception handler appearing first in code
 * @param generalException - The general exception type handled by generalHandler
 * @param specificHandler - The exception handler appearing later in code
 * @param specificException - The specific exception type handled by specificHandler
 */
predicate hasIncorrectHandlerOrder(ExceptStmt generalHandler, ClassValue generalException, 
                                  ExceptStmt specificHandler, ClassValue specificException) {
  // Verify handlers belong to same try-block with correct ordering
  exists(int generalIndex, int specificIndex, Try tryStmt |
    generalHandler = tryStmt.getHandler(generalIndex) and
    specificHandler = tryStmt.getHandler(specificIndex) and
    generalIndex < specificIndex
  ) and
  // Retrieve exception types and verify inheritance relationship
  generalException = getHandledExceptionClass(generalHandler) and
  specificException = getHandledExceptionClass(specificHandler) and
  generalException = specificException.getASuperType()
}

// Main query detecting unreachable exception handlers
from ExceptStmt specificHandler, ClassValue specificException, 
     ExceptStmt generalHandler, ClassValue generalException
where hasIncorrectHandlerOrder(generalHandler, generalException, 
                              specificHandler, specificException)
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), generalHandler, "except block", generalException, generalException.getName()