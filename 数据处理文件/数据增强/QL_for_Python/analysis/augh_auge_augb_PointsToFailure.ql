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

// Find expressions lacking object references in the control flow graph
from Expr exprWithoutRef
where 
    // Check for existence of a control flow node associated with the expression
    exists(ControlFlowNode cfNode | 
        // Establish the relationship between expression and its control flow node
        cfNode = exprWithoutRef.getAFlowNode() and
        // Verify that the control flow node does not reference any object
        not cfNode.refersTo(_)
    )
// Report the identified expression with diagnostic information
select exprWithoutRef, "Expression does not 'point-to' any object."