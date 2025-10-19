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

from Expr failedPointsToExpr
where not exists(ControlFlowNode cfgNode | 
    // Check if the expression has a control flow node that refers to any object
    cfgNode = failedPointsToExpr.getAFlowNode() and 
    cfgNode.refersTo(_)
)
select failedPointsToExpr, "Expression does not 'point-to' any object."