/**
 * @name Critical expression points-to analysis failure.
 * @description Detects expressions that are unable to point-to any object, which obstructs subsequent points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Predicate that determines if an expression fails to establish a points-to relationship with any object
predicate exprPointsToFailure(Expr problematicExpr) {
  // Check for the existence of a control flow node related to the expression that has no points-to connections
  exists(ControlFlowNode flowNode | 
    flowNode = problematicExpr.getAFlowNode() | 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

// Predicate that identifies expressions with critical points-to analysis failures
predicate isKeyPointsToFailure(Expr problematicExpr) {
  // Core condition: the expression itself has a points-to failure
  exprPointsToFailure(problematicExpr) and
  // Sub-expression condition: all sub-expressions have successful points-to analysis
  not exprPointsToFailure(problematicExpr.getASubExpression()) and
  // SSA variable condition: no SSA variables utilizing this expression have definition nodes with points-to failures
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = problematicExpr.getAFlowNode() |
    exprPointsToFailure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Assignment condition: the expression is not the target of an assignment statement
  not exists(Assign assignStmt | assignStmt.getATarget() = problematicExpr)
}

// Query that retrieves all critical points-to failure expressions, excluding those utilized as function calls
from Attribute problematicExpr
where 
  // Apply the critical points-to failure filter
  isKeyPointsToFailure(problematicExpr) and
  // Exclude expressions used as function calls
  not exists(Call funcCall | funcCall.getFunc() = problematicExpr)
select problematicExpr, "Expression does not 'point-to' any object, but all its sources do."