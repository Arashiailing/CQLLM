/**
 * @name Critical expression points-to analysis failure.
 * @description Identifies expressions that fail to point-to any object, blocking further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Predicate to identify expressions that cannot point to any object
predicate exprPointsToFailure(Expr failingExpr) {
  // Verify if there's a control flow node associated with the expression that lacks any points-to relationship
  exists(ControlFlowNode cfgNode | 
    cfgNode = failingExpr.getAFlowNode() | 
    not PointsTo::pointsTo(cfgNode, _, _, _)
  )
}

// Predicate to identify critical points-to analysis failures in expressions
predicate isKeyPointsToFailure(Expr failingExpr) {
  // Confirm the expression itself experiences points-to failure
  exprPointsToFailure(failingExpr) and
  // Ensure all sub-expressions have successful points-to analysis
  not exprPointsToFailure(failingExpr.getASubExpression()) and
  // Verify that no SSA variables using this expression have definition nodes with points-to failures
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = failingExpr.getAFlowNode() |
    exprPointsToFailure(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Confirm the expression is not the target of an assignment operation
  not exists(Assign assignment | assignment.getATarget() = failingExpr)
}

// Query to find all critical points-to failure expressions, excluding those used as function calls
from Attribute failingExpr
where isKeyPointsToFailure(failingExpr) and not exists(Call call | call.getFunc() = failingExpr)
select failingExpr, "Expression does not 'point-to' any object, but all its sources do."