/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that are never executed due to incorrect ordering,
 *              where a broader exception handler precedes a more specific one, catching all exceptions first.
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

// This query detects Python exception handling blocks that become unreachable
// due to improper ordering of exception types in try-except constructs
from ExceptStmt precedingHandler, ClassValue generalException, 
     ExceptStmt succeedingHandler, ClassValue specificException
where exists(int precedingIdx, int succeedingIdx, Try enclosingTry |
  // Verify both handlers belong to the same try-except statement
  precedingHandler = enclosingTry.getHandler(precedingIdx) and
  succeedingHandler = enclosingTry.getHandler(succeedingIdx) and
  
  // Ensure source code ordering: general exception handler appears first
  precedingIdx < succeedingIdx and
  
  // Extract the exception types handled by each except clause
  precedingHandler.getType().pointsTo(generalException) and
  succeedingHandler.getType().pointsTo(specificException) and
  
  // Confirm inheritance relationship that makes the specific handler unreachable
  generalException = specificException.getASuperType()
)
// Generate alert with the unreachable block and detailed explanation
select succeedingHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()