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

// Select expressions that have control flow nodes which don't refer to any object
from Expr problematicExpr
where 
  // Check if there exists a control flow node associated with this expression
  exists(ControlFlowNode controlFlowNode | 
    controlFlowNode = problematicExpr.getAFlowNode() and
    // Verify that the control flow node doesn't point to any object
    not controlFlowNode.refersTo(_)
  )
// Output the problematic expression with a descriptive message
select problematicExpr, "Expression does not 'point-to' any object."