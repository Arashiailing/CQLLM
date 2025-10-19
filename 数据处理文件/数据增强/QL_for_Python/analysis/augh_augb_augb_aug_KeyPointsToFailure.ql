/**
 * @name Points-to analysis failure for expressions.
 * @description Identifies expressions that fail to reference any object, which obstructs points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/points-to-analysis-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Determine if an expression fails to point to any object during analysis
predicate pointsToAnalysisFailed(Expr problematicExpr) {
  // Check if there's a control flow node associated with the expression
  // that lacks any points-to relationships
  exists(ControlFlowNode controlFlowNode | 
    controlFlowNode = problematicExpr.getAFlowNode() | 
    not PointsTo::pointsTo(controlFlowNode, _, _, _)
  )
}

// Identify expressions with critical points-to failures
predicate isCriticalPointsToFailure(Expr problematicExpr) {
  // The expression itself fails points-to analysis
  pointsToAnalysisFailed(problematicExpr) and
  // All sub-expressions pass points-to analysis
  not pointsToAnalysisFailed(problematicExpr.getASubExpression()) and
  // No SSA variable using this expression has a failing definition
  not exists(SsaVariable ssaVariable | 
    ssaVariable.getAUse() = problematicExpr.getAFlowNode() |
    pointsToAnalysisFailed(ssaVariable.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // The expression is not the target of an assignment
  not exists(Assign assignment | assignment.getATarget() = problematicExpr)
}

// Find attribute expressions with critical points-to failures that are not function calls
from Attribute problematicExpr
where 
  isCriticalPointsToFailure(problematicExpr) and 
  not exists(Call functionCall | functionCall.getFunc() = problematicExpr)
select problematicExpr, "Expression does not 'point-to' any object, but all its sources do."