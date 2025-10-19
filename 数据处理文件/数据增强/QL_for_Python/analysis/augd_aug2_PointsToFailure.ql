/**
 * @name points-to fails for expression.
 * @description Identifies expressions that fail to point-to any object, which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python library for analyzing Python code
import python

// Identify expressions with control flow nodes that don't reference any object
from Expr exprWithoutPointTo
where 
  // Verify existence of a control flow node for this expression
  exists(ControlFlowNode cfNode | 
    cfNode = exprWithoutPointTo.getAFlowNode() and
    // Ensure the control flow node has no point-to target
    not cfNode.refersTo(_)
  )
// Report the expression with diagnostic message
select exprWithoutPointTo, "Expression does not 'point-to' any object."