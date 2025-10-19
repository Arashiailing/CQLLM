/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import the Python module to enable code analysis capabilities
import python

// Identify expressions that fail to point-to any object during analysis
from Expr problematicExpr, ControlFlowNode correspondingFlowNode
where 
  // Establish the relationship between the expression and its control flow node
  correspondingFlowNode = problematicExpr.getAFlowNode() and
  // Ensure that the control flow node does not reference any object
  not correspondingFlowNode.refersTo(_)
// Report the problematic expression with an informative message
select problematicExpr, "Expression does not 'point-to' any object."