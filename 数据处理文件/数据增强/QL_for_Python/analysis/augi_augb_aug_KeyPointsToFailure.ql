/**
 * @name Expression points-to analysis failure.
 * @description Detects expressions that fail to resolve to any object reference, hindering points-to analysis progression.
 * @kind problem
 * @problem.severity info
 * @id py/points-to-analysis-failure
 * @deprecated
 */

import python
import semmle.python.pointsto.PointsTo

// Predicate to identify expressions that cannot resolve to any object reference
predicate exprPointsToAnalysisFailure(Expr expr) {
  // Check for control flow nodes associated with the expression that lack any points-to relationships
  exists(ControlFlowNode cfgNode | 
    cfgNode = expr.getAFlowNode() | 
    not PointsTo::pointsTo(cfgNode, _, _, _)
  )
}

// Predicate to identify critical points-to analysis failures
predicate isCriticalFailure(Expr expr) {
  // Primary condition: Expression itself has points-to failure
  exprPointsToAnalysisFailure(expr) and
  // Recursive condition: All sub-expressions have valid points-to analysis
  not exprPointsToAnalysisFailure(expr.getASubExpression()) and
  // SSA variable condition: No SSA variable using this expression has a failing definition node
  not exists(SsaVariable ssaVar | 
    ssaVar.getAUse() = expr.getAFlowNode() |
    exprPointsToAnalysisFailure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  // Assignment condition: Expression is not the target of an assignment operation
  not exists(Assign assignment | assignment.getATarget() = expr)
}

// Query: Find all critical points-to failures excluding function call expressions
from Attribute expr
where isCriticalFailure(expr) and not exists(Call call | call.getFunc() = expr)
select expr, "Expression does not 'point-to' any object, but all its sources do."