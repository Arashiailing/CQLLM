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

// Locate expressions lacking object references
from Expr exprWithoutRef
where exists(ControlFlowNode cfNode | 
    // Establish connection between expression and its control flow node
    cfNode = exprWithoutRef.getAFlowNode() and
    // Verify the control flow node has no object reference
    not cfNode.refersTo(_)
)
// Report the expression with appropriate diagnostic message
select exprWithoutRef, "Expression does not 'point-to' any object."