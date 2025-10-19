/**
 * @name Key points-to fails for expression.
 * @description Expression does not "point-to" an object which prevents further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

/**
 * Determines if an expression has points-to analysis failure.
 * Holds when the expression's control flow node has no points-to relations.
 */
predicate points_to_failure(Expr targetExpr) {
  exists(ControlFlowNode flowNode | 
    flowNode = targetExpr.getAFlowNode() and 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

/**
 * Identifies critical points-to failures where:
 * 1. The expression itself has points-to failure
 * 2. All sub-expressions have successful points-to analysis
 * 3. No SSA variable using this expression has a failing definition
 * 4. The expression is not the target of an assignment
 */
predicate key_points_to_failure(Expr targetExpr) {
  // Core condition: Expression has points-to failure
  points_to_failure(targetExpr) and
  
  // Sub-expression condition: No child expressions have points-to failure
  forall(Expr subExpr | subExpr = targetExpr.getASubExpression() | not points_to_failure(subExpr)) and
  
  // SSA variable condition: No related SSA variables have failing definitions
  forall(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = targetExpr.getAFlowNode() |
    not points_to_failure(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  
  // Assignment target condition: Expression is not an assignment target
  not exists(Assign assignStmt | assignStmt.getATarget() = targetExpr)
}

// Query: Find attribute expressions with critical points-to failures
// that are not part of a call expression
from Attribute attributeExpr
where 
  key_points_to_failure(attributeExpr) and 
  not exists(Call callExpr | callExpr.getFunc() = attributeExpr)
select attributeExpr, "Expression does not 'point-to' any object, but all its sources do."