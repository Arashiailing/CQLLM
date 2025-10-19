/**
 * @name Unreachable 'except' block
 * @description Identifies unreachable exception handlers caused by improper ordering,
 *              where a general exception handler precedes a specific one,
 *              making the specific handler unreachable.
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

// Determines if a specific exception handler is unreachable due to being positioned
// after a more general handler that catches its superclass exception
predicate isUnreachableHandler(ExceptStmt generalHandler, ClassValue generalException, 
                               ExceptStmt specificHandler, ClassValue specificException) {
  exists(int generalIdx, int specificIdx, Try tryStmt |
    // Both handlers belong to the same try statement
    generalHandler = tryStmt.getHandler(generalIdx) and
    specificHandler = tryStmt.getHandler(specificIdx) and
    // General handler appears before specific handler in source order
    generalIdx < specificIdx and
    // Extract exception types for both handlers
    generalHandler.getType().pointsTo(generalException) and
    specificHandler.getType().pointsTo(specificException) and
    // General handler catches superclass of specific handler's exception
    generalException = specificException.getASuperType()
  )
}

// Main query identifying all unreachable exception handlers
from ExceptStmt generalHandler, ClassValue generalException, 
     ExceptStmt specificHandler, ClassValue specificException
where isUnreachableHandler(generalHandler, generalException, specificHandler, specificException)
select specificHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), generalHandler, "except block", generalException, generalException.getName()