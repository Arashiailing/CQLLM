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
predicate points_to_failure(Expr expr) {
  exists(ControlFlowNode flowNode | 
    flowNode = expr.getAFlowNode() and 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

/**
 * Identifies critical points-to failures where:
 * 1. The expression itself has points-to failure
 * 2. None of its sub-expressions have points-to failure
 * 3. No SSA variable using this expression has a failing definition
 * 4. The expression is not the target of an assignment
 */
predicate key_points_to_failure(Expr expr) {
  points_to_failure(expr) and
  not points_to_failure(expr.getASubExpression()) and
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = expr.getAFlowNode() and
    points_to_failure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  not exists(Assign assign | assign.getATarget() = expr)
}

// Query: Find attribute expressions with critical points-to failures
// that are not part of a call expression
from Attribute expr
where 
  key_points_to_failure(expr) and 
  not exists(Call call | call.getFunc() = expr)
select expr, "Expression does not 'point-to' any object, but all its sources do."