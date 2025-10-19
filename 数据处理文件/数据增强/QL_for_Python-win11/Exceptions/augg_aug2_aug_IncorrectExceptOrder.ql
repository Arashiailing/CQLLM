/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute due to incorrect ordering.
 *              When a general exception handler precedes a specific one (where the specific
 *              exception inherits from the general one), the specific handler becomes unreachable.
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
 * Maps an exception handler statement to its handled exception class.
 * @param handler - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by the handler
 */
ClassValue getHandledExceptionClass(ExceptStmt handler) { 
  handler.getType().pointsTo(result) 
}

/**
 * Identifies incorrectly ordered exception handlers where a general handler
 * precedes a specific handler that inherits from the general exception type.
 * @param generalHandler - The handler for the general exception type
 * @param generalException - The general exception type handled first
 * @param specificHandler - The handler for the specific exception type
 * @param specificException - The specific exception type handled later
 */
predicate hasIncorrectHandlerOrder(ExceptStmt generalHandler, ClassValue generalException, 
                                 ExceptStmt specificHandler, ClassValue specificException) {
  // Verify both handlers belong to the same try block with correct ordering
  exists(int generalIndex, int specificIndex, Try tryBlock |
    generalHandler = tryBlock.getHandler(generalIndex) and
    specificHandler = tryBlock.getHandler(specificIndex) and
    generalIndex < specificIndex
  ) and
  // Establish exception type relationships
  generalException = getHandledExceptionClass(generalHandler) and
  specificException = getHandledExceptionClass(specificHandler) and
  // Confirm inheritance relationship (specific exception inherits from general)
  generalException = specificException.getASuperType()
}

// Main query to detect unreachable exception handlers
from ExceptStmt specificHandler, ClassValue specificException, 
     ExceptStmt generalHandler, ClassValue generalException
where hasIncorrectHandlerOrder(generalHandler, generalException, 
                              specificHandler, specificException)
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), generalHandler, "except block", generalException, generalException.getName()