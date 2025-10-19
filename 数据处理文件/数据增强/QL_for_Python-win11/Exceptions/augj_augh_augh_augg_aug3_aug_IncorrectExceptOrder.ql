/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that become unreachable due to incorrect ordering.
 *              When a general exception type is caught before its specific subtype,
 *              the specialized handler is never executed because the general handler
 *              intercepts all exceptions first.
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

/**
 * Extracts the exception class handled by an exception statement.
 * @param exceptStmt - The exception statement to examine
 * @return The class value representing the caught exception type
 */
ClassValue getHandledExceptionClass(ExceptStmt exceptStmt) { 
  exceptStmt.getType().pointsTo(result) 
}

/**
 * Finds exception handlers with incorrect ordering where a general exception
 * precedes its specific subtype, rendering the specific handler unreachable.
 * @param earlierHandler - The exception handler appearing first in code
 * @param generalException - The broad exception class handled earlier
 * @param laterHandler - The exception handler appearing later in code
 * @param specificException - The specific exception class handled later
 */
predicate findExceptOrderingDefect(ExceptStmt earlierHandler, ClassValue generalException, 
                                  ExceptStmt laterHandler, ClassValue specificException) {
  exists(Try tryBlock, int firstIndex, int secondIndex |
    // Both handlers must be part of the same try block
    earlierHandler = tryBlock.getHandler(firstIndex) and
    laterHandler = tryBlock.getHandler(secondIndex) and
    // Ensure correct sequence: earlier handler comes before later handler
    firstIndex < secondIndex and
    // Retrieve exception types from both handlers
    generalException = getHandledExceptionClass(earlierHandler) and
    specificException = getHandledExceptionClass(laterHandler) and
    // Verify inheritance relationship: general exception is a superclass
    generalException = specificException.getASuperType()
  )
}

// Main query to detect all unreachable exception handlers
from ExceptStmt laterHandler, ClassValue specificException, 
     ExceptStmt earlierHandler, ClassValue generalException
where findExceptOrderingDefect(earlierHandler, generalException, 
                             laterHandler, specificException)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", generalException, generalException.getName()