/**
 * @name Expression points-to analysis failure
 * @description Identifies expressions that fail to resolve to any object reference,
 *              which can impede accurate type inference and static analysis.
 * @kind problem
 * @id py/points-to-failure
 * @problem.severity info
 * @tags debug
 * @deprecated
 */

// Import the Python library for code analysis
import python

from Expr unresolvedExpr
where 
    // Verify that the expression lacks any control flow node that refers to an object
    not exists(ControlFlowNode flowNode | 
        flowNode = unresolvedExpr.getAFlowNode() and 
        flowNode.refersTo(_)
    )
select unresolvedExpr, "Expression does not 'point-to' any object."