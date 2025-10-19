/**
 * @name Key points-to fails for expression.
 * @description Identifies expressions that fail to point-to any object, preventing further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

/**
 * Determines if an expression fails to point-to any object.
 * @param expr The expression to check.
 */
predicate expressionPointsToFailure(Expr expr) {
  exists(ControlFlowNode flowNode | 
    flowNode = expr.getAFlowNode() and 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

/**
 * Identifies key expressions that fail points-to analysis.
 * A key expression is one that fails points-to analysis itself,
 * but all its sources (sub-expressions) do not.
 * @param expr The expression to check.
 */
predicate isKeyPointsToFailure(Expr expr) {
  // The expression itself fails points-to analysis
  expressionPointsToFailure(expr) and
  // None of its sub-expressions fail points-to analysis
  not expressionPointsToFailure(expr.getASubExpression()) and
  // There is no SSA variable using this expression's flow node
  // whose definition node also fails points-to analysis
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = expr.getAFlowNode() and
    expressionPointsToFailure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // The expression is not the target of an assignment
  not exists(Assign assignment | assignment.getATarget() = expr)
}

// Query to find all Attribute expressions that are key points-to failures
// and are not part of a call expression
from Attribute attrExpr
where 
  isKeyPointsToFailure(attrExpr) and 
  not exists(Call call | call.getFunc() = attrExpr)
select attrExpr, "Expression does not 'point-to' any object, but all its sources do."