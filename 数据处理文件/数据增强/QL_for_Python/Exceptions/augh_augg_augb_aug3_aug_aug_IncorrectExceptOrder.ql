/**
 * @name Unreachable 'except' block
 * @description Identifies exception handlers that become unreachable due to positioning
 *              after more general handlers which intercept exceptions first.
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

// Detect unreachable exception handlers caused by improper handler ordering
from ExceptStmt subsequentHandler, ClassValue derivedException,
     ExceptStmt precedingHandler, ClassValue baseException
where exists(Try enclosingTry, int precedingPosition, int subsequentPosition |
    // Both handlers belong to the same try statement
    precedingHandler = enclosingTry.getHandler(precedingPosition) and
    subsequentHandler = enclosingTry.getHandler(subsequentPosition) and
    // Preceding handler appears before subsequent handler
    precedingPosition < subsequentPosition and
    // Resolve exception types handled by each block
    precedingHandler.getType().pointsTo(baseException) and
    subsequentHandler.getType().pointsTo(derivedException) and
    // Preceding handler catches a superclass of the subsequent handler's exception
    baseException = derivedException.getASuperType()
  )
// Generate alert for the unreachable handler
select subsequentHandler,
  "Except block for $@ is unreachable; the more general $@ for $@ will always be executed in preference.",
  derivedException, derivedException.getName(), precedingHandler, "except block", baseException, baseException.getName()