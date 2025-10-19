/**
 * @name points-to fails for expression.
 * @description Expression fails to reference an object, which blocks type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python library for analyzing Python code
import python

// Select expressions that have no point-to target
from Expr exprToCheck
// Check if there exists a flow node for the expression that doesn't refer to any object
where exists(ControlFlowNode flowNode | 
    flowNode = exprToCheck.getAFlowNode() and 
    not flowNode.refersTo(_)
)
// Output the problematic expression with descriptive message
select exprToCheck, "Expression does not 'point-to' any object."