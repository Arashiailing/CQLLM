/**
 * @name points-to fails for expression.
 * @description Identifies expressions that fail to point-to any object, which impedes type inference.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python analysis capabilities for static code analysis
import python

// Find expressions that have control flow nodes but fail to reference any object
from Expr failedPointToExpr
where 
    // Ensure the expression has at least one associated control flow node
    exists(ControlFlowNode flowNode | 
        flowNode = failedPointToExpr.getAFlowNode()
    ) and
    // Confirm that none of the expression's control flow nodes reference any object
    forall(ControlFlowNode flowNode | 
        flowNode = failedPointToExpr.getAFlowNode() |
        not flowNode.refersTo(_)
    )
// Report the expression with a descriptive message
select failedPointToExpr, "Expression does not 'point-to' any object."