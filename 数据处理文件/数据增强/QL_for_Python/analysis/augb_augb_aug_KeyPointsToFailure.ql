/**
 * @name Expression points-to analysis failure.
 * @description Detects expressions that cannot point to any object, hindering points-to analysis.
 * @kind problem
 * @problem.severity info
 * @id py/points-to-analysis-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Check if an expression fails to point to any object
predicate pointsToAnalysisFailed(Expr targetExpr) {
  // Verify there's a control flow node associated with the expression
  // that has no points-to relationships
  exists(ControlFlowNode flowNode | 
    flowNode = targetExpr.getAFlowNode() | 
    not PointsTo::pointsTo(flowNode, _, _, _)
  )
}

// Identify critical points-to failures in expressions
predicate isCriticalPointsToFailure(Expr targetExpr) {
  // Base condition: the expression itself fails points-to analysis
  pointsToAnalysisFailed(targetExpr) and
  // Recursive condition: all sub-expressions pass points-to analysis
  not pointsToAnalysisFailed(targetExpr.getASubExpression()) and
  // SSA condition: no SSA variable using this expression has a failing definition
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = targetExpr.getAFlowNode() |
    pointsToAnalysisFailed(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Assignment condition: expression is not the target of an assignment
  not exists(Assign assignStmt | assignStmt.getATarget() = targetExpr)
}

// Find all critical points-to failures that are not function calls
from Attribute targetExpr
where 
  isCriticalPointsToFailure(targetExpr) and 
  not exists(Call funcCall | funcCall.getFunc() = targetExpr)
select targetExpr, "Expression does not 'point-to' any object, but all its sources do."