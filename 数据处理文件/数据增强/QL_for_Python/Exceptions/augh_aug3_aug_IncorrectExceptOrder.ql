/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that can never execute because a broader
 *              exception handler precedes them in the same try statement.
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

from ExceptStmt laterHandler, ClassValue specificException,
     ExceptStmt earlierHandler, ClassValue baseException
where exists(int earlierIndex, int laterIndex, Try enclosingTry |
    // Both handlers belong to the same try statement
    earlierHandler = enclosingTry.getHandler(earlierIndex) and
    laterHandler = enclosingTry.getHandler(laterIndex) and
    // Verify handler ordering: earlier appears before later
    earlierIndex < laterIndex and
    // Extract exception types for both handlers
    earlierHandler.getType().pointsTo(baseException) and
    laterHandler.getType().pointsTo(specificException) and
    // Check inheritance: base exception is a superclass
    baseException = specificException.getASuperType()
)
select laterHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), earlierHandler, "except block", baseException, baseException.getName()