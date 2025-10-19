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
predicate exprPointsToFailure(Expr problematicExpr) {
  // Check if any control flow node associated with the expression lacks points-to relationships
  exists(ControlFlowNode controlFlowNode | 
    controlFlowNode = problematicExpr.getAFlowNode() | 
    not PointsTo::pointsTo(controlFlowNode, _, _, _)
  )
}

// Predicate to identify critical points-to analysis failures in expressions
predicate isKeyPointsToFailure(Expr problematicExpr) {
  // The expression itself experiences points-to failure
  exprPointsToFailure(problematicExpr) and
  // All sub-expressions have successful points-to analysis
  not exprPointsToFailure(problematicExpr.getASubExpression()) and
  // The expression is not involved in any points-to failure propagation through SSA variables
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = problematicExpr.getAFlowNode() |
    exprPointsToFailure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // The expression is not the target of an assignment operation
  not exists(Assign assignStmt | assignStmt.getATarget() = problematicExpr)
}

// Query to find all critical points-to failure expressions, excluding those used as function calls
from Attribute problematicExpr
where isKeyPointsToFailure(problematicExpr) and not exists(Call call | call.getFunc() = problematicExpr)
select problematicExpr, "Expression does not 'point-to' any object, but all its sources do."