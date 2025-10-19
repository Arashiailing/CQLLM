/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python module for code analysis
import python

// Select expressions that fail to point-to any object
from Expr expr
where 
  // Find a control flow node corresponding to the expression
  exists(ControlFlowNode flowNode | 
    flowNode = expr.getAFlowNode() and
    // Check that the flow node does not refer to any object
    not flowNode.refersTo(_)
  )
// Output the problematic expression with a descriptive message
select expr, "Expression does not 'point-to' any object."