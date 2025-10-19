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
predicate hasPointsToFailure(Expr expr) {
  exists(ControlFlowNode controlFlowNode | 
    controlFlowNode = expr.getAFlowNode() and 
    not PointsTo::pointsTo(controlFlowNode, _, _, _)
  )
}

/**
 * Identifies critical points-to failures where:
 * 1. The expression itself has points-to failure
 * 2. None of its sub-expressions have points-to failure
 * 3. No SSA variable using this expression has a failing definition
 * 4. The expression is not the target of an assignment
 */
predicate isKeyPointsToFailure(Expr expr) {
  // Condition 1: The expression itself has points-to failure
  hasPointsToFailure(expr) and
  // Condition 2: None of its sub-expressions have points-to failure
  not hasPointsToFailure(expr.getASubExpression()) and
  // Condition 3: No SSA variable using this expression has a failing definition
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = expr.getAFlowNode() and
    hasPointsToFailure(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Condition 4: The expression is not the target of an assignment
  not exists(Assign assignment | assignment.getATarget() = expr)
}

// Query: Find attribute expressions with critical points-to failures
// that are not part of a call expression
from Attribute targetExpr
where 
  isKeyPointsToFailure(targetExpr) and 
  not exists(Call call | call.getFunc() = targetExpr)
select targetExpr, "Expression does not 'point-to' any object, but all its sources do."