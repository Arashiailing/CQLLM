/**
 * @name Expression fails to point-to an object
 * @description This query identifies Python expressions that contain at least one
 *              control flow node which doesn't reference any object. Such expressions
 *              can hinder proper type inference and static analysis.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import necessary Python modules for code analysis
import python

// Identify expressions that have control flow nodes not referencing any object
from Expr problematicExpression
where 
    // There exists at least one control flow node for the expression
    exists(ControlFlowNode flowNode | 
        // The control flow node belongs to the expression
        flowNode = problematicExpression.getAFlowNode() and 
        // The control flow node doesn't reference any object
        not flowNode.refersTo(_)
    )
// Report the identified expression with a descriptive message
select problematicExpression, "Expression does not 'point-to' any object."