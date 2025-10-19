/**
 * @name points-to fails for expression.
 * @description Identifies Python expressions that do not point-to any object,
 *              which can prevent proper type inference and static analysis.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import the Python module for CodeQL analysis
import python

// Identify expressions that fail to establish a 'point-to' relationship with any object
from Expr exprWithoutPointTo, ControlFlowNode associatedFlowNode
where 
    // Link the flow node to the expression
    associatedFlowNode = exprWithoutPointTo.getAFlowNode()
    // Ensure the flow node doesn't reference any object
    and not associatedFlowNode.refersTo(_)
// Report the identified expression with a descriptive message
select exprWithoutPointTo, "Expression does not 'point-to' any object."