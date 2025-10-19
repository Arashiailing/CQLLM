/**
 * @name points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python analysis module for code inspection
import python

// Identify expressions that lack object references
from Expr problematicExpr
// Verify existence of a control flow node associated with the expression
// that fails to reference any object
where exists(ControlFlowNode flowNode | 
    // Establish relationship between expression and its control flow node
    flowNode = problematicExpr.getAFlowNode() and
    // Confirm the control flow node has no object reference
    not flowNode.refersTo(_)
)
// Report the problematic expression with diagnostic message
select problematicExpr, "Expression does not 'point-to' any object."