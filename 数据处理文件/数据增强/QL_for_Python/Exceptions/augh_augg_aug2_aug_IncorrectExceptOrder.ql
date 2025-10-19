/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are unreachable due to incorrect ordering.
 *              When a general exception handler is placed before a specific one (where the specific
 *              exception type inherits from the general one), the specific handler becomes unreachable.
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
 * Retrieves the exception class handled by an exception handler statement.
 * @param exceptionHandler - The exception handler statement to analyze
 * @return - The ClassValue representing the exception type handled by the exception handler
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptionHandler) { 
  exceptionHandler.getType().pointsTo(result) 
}

/**
 * Detects exception handlers with incorrect ordering where a general handler
 * precedes a specific handler that inherits from the general exception type.
 * @param generalExceptionHandler - The handler for the general exception type
 * @param generalExceptionType - The general exception type handled first
 * @param specificExceptionHandler - The handler for the specific exception type
 * @param specificExceptionType - The specific exception type handled later
 */
predicate hasIncorrectHandlerOrder(ExceptStmt generalExceptionHandler, ClassValue generalExceptionType, 
                                 ExceptStmt specificExceptionHandler, ClassValue specificExceptionType) {
  // Verify both handlers belong to the same try block with correct ordering
  exists(int generalHandlerIndex, int specificHandlerIndex, Try tryStatement |
    generalExceptionHandler = tryStatement.getHandler(generalHandlerIndex) and
    specificExceptionHandler = tryStatement.getHandler(specificHandlerIndex) and
    generalHandlerIndex < specificHandlerIndex
  ) and
  // Establish exception type relationships
  generalExceptionType = getHandledExceptionClass(generalExceptionHandler) and
  specificExceptionType = getHandledExceptionClass(specificExceptionHandler) and
  // Confirm inheritance relationship (specific exception inherits from general)
  generalExceptionType = specificExceptionType.getASuperType()
}

// Main query to identify unreachable exception handlers
from ExceptStmt specificExceptionHandler, ClassValue specificExceptionType, 
     ExceptStmt generalExceptionHandler, ClassValue generalExceptionType
where hasIncorrectHandlerOrder(generalExceptionHandler, generalExceptionType, 
                              specificExceptionHandler, specificExceptionType)
select specificExceptionHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificExceptionType, specificExceptionType.getName(), generalExceptionHandler, "except block", generalExceptionType, generalExceptionType.getName()