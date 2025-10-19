/**
 * @name Expression points-to analysis failure
 * @description Identifies expressions that fail to point-to any object, 
 *              which may indicate type inference issues.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import Python analysis library for static code analysis capabilities
import python

// Identify expressions that fail to resolve to any concrete object
from Expr exprWithoutPointsTo
where 
    // Check if any control flow node associated with the expression
    // fails to reference any object
    exists(ControlFlowNode flowNode | 
        // Verify the flow node belongs to the target expression
        flowNode = exprWithoutPointsTo.getAFlowNode() 
        // Confirm the flow node doesn't reference any object
        and not flowNode.refersTo(_)
    )
// Output expression nodes with descriptive message
select exprWithoutPointsTo, "Expression fails to 'point-to' any object."