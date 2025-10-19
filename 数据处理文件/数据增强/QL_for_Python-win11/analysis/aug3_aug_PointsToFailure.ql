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

// Identify expressions that have control flow nodes but do not reference any object
from Expr problematicExpression
where 
    // Check if the expression has at least one control flow node
    exists(ControlFlowNode cfNode | 
        cfNode = problematicExpression.getAFlowNode()
    ) and
    // Verify that none of the control flow nodes of this expression refer to any object
    forall(ControlFlowNode cfNode | 
        cfNode = problematicExpression.getAFlowNode() |
        not cfNode.refersTo(_)
    )
// Output the problematic expression node with descriptive message
select problematicExpression, "Expression does not 'point-to' any object."