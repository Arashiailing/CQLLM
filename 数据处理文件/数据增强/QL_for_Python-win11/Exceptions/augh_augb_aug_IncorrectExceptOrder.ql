/**
 * @name Unreachable 'except' block
 * @description Identifies except blocks that can never be executed due to improper ordering.
 *              When a general exception handler (catching a parent exception class) is placed
 *              before a specific exception handler (catching a child exception class), the specific
 *              handler becomes unreachable because the general handler will always catch the exception first.
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

// Detects exception handlers where a general exception class handler
// precedes a more specific exception class handler in the same try block
predicate findUnreachableExceptionHandler(ExceptStmt generalHandler, ClassValue baseException, 
                                        ExceptStmt specificHandler, ClassValue derivedException) {
  exists(int generalIdx, int specificIdx, Try tryBlock |
    // Both handlers must belong to the same try statement
    generalHandler = tryBlock.getHandler(generalIdx) and
    specificHandler = tryBlock.getHandler(specificIdx) and
    // General handler must appear before specific handler
    generalIdx < specificIdx and
    // Extract exception types directly from handlers
    generalHandler.getType().pointsTo(baseException) and
    specificHandler.getType().pointsTo(derivedException) and
    // Verify inheritance relationship (base is superclass of derived)
    baseException = derivedException.getASuperType()
  )
}

// Identify all unreachable exception handlers due to incorrect ordering
from ExceptStmt specificHandler, ClassValue derivedException, 
     ExceptStmt generalHandler, ClassValue baseException
where findUnreachableExceptionHandler(generalHandler, baseException, 
                                    specificHandler, derivedException)
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), generalHandler, "except block", baseException, baseException.getName()