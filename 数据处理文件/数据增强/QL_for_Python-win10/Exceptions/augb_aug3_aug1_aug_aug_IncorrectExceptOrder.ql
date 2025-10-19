/**
 * @name Unreachable 'except' block
 * @description Detects exception handlers that become unreachable due to improper ordering,
 *              where a general handler precedes a specific one, intercepting all exceptions first.
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

// Main query identifying unreachable exception handlers
from ExceptStmt precedingHandler, ClassValue generalException, 
     ExceptStmt subsequentHandler, ClassValue specificException
where exists(int precedingIndex, int subsequentIndex, Try enclosingTry |
  // Both handlers belong to the same try statement
  precedingHandler = enclosingTry.getHandler(precedingIndex) and
  subsequentHandler = enclosingTry.getHandler(subsequentIndex) and
  // Source code ordering: general handler appears first
  precedingIndex < subsequentIndex and
  // Extract exception types handled by each clause
  precedingHandler.getType().pointsTo(generalException) and
  subsequentHandler.getType().pointsTo(specificException) and
  // Verify inheritance relationship making later handler unreachable
  generalException = specificException.getASuperType()
)
// Generate result with unreachable block and contextual warning
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  specificException, specificException.getName(), precedingHandler, "except block", generalException, generalException.getName()