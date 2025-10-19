/**
 * @name points-to fails for expression.
 * @description Identifies expressions that fail to point-to any object, which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import the Python analysis library
import python

// Find expressions that have at least one control flow node which does not refer to any object
from Expr exprWithFailedPointTo
where 
  // Check if there exists a control flow node associated with the expression that does not refer to any object
  exists(ControlFlowNode cfNode | 
    cfNode = exprWithFailedPointTo.getAFlowNode() and
    not cfNode.refersTo(_)
  )
// Report the expression with an informative message
select exprWithFailedPointTo, "Expression does not 'point-to' any object."