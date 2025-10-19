/**
 * @name Key points-to fails for expression.
 * @description Identifies expressions that fail to point-to any object, blocking further points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/key-points-to-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Predicate to determine if an expression fails to point-to any object
predicate expressionLacksPointToTarget(Expr problematicExpr) {
  // Check if there's a control flow node associated with the expression that has no points-to relations
  exists(ControlFlowNode controlFlowNode | 
    controlFlowNode = problematicExpr.getAFlowNode() | 
    not PointsTo::pointsTo(controlFlowNode, _, _, _)
  )
}

// Predicate to identify critical points-to failure expressions that meet specific criteria
predicate representsCriticalPointToFailure(Expr problematicExpr) {
  // Verify the expression itself has points-to failure
  expressionLacksPointToTarget(problematicExpr) and
  // Ensure all sub-expressions have successful points-to relationships
  not expressionLacksPointToTarget(problematicExpr.getASubExpression()) and
  // Confirm no SSA variables using this expression have definition nodes with points-to failure
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = problematicExpr.getAFlowNode() |
    expressionLacksPointToTarget(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Ensure the expression is not the target of an assignment operation
  not exists(Assign assignment | assignment.getATarget() = problematicExpr)
}

// Main query: Find all critical points-to failure expressions, excluding those used as function calls
from Attribute problematicExpr
where 
  representsCriticalPointToFailure(problematicExpr) and 
  not exists(Call functionCall | functionCall.getFunc() = problematicExpr)
select problematicExpr, "Expression does not 'point-to' any object, but all its sources do."