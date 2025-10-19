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
 * Identifies expressions that lack points-to relations.
 * This predicate holds when an expression's control flow node
 * has no associated points-to information.
 */
predicate points_to_failure(Expr problematicExpr) {
  exists(ControlFlowNode cfNode | 
    cfNode = problematicExpr.getAFlowNode() and 
    not PointsTo::pointsTo(cfNode, _, _, _)
  )
}

/**
 * Detects critical points-to analysis failures with specific characteristics:
 * - The expression itself has points-to failure
 * - All child expressions have successful points-to analysis
 * - No SSA variable using this expression has a failing definition
 * - The expression is not the target of an assignment operation
 */
predicate key_points_to_failure(Expr problematicExpr) {
  // The expression has points-to failure
  points_to_failure(problematicExpr) and
  
  // All child expressions have successful points-to analysis
  forall(Expr childExpr | 
    childExpr = problematicExpr.getASubExpression() | 
    not points_to_failure(childExpr)
  ) and
  
  // No SSA variables using this expression have failing definitions
  forall(SsaVariable ssaVar | 
    ssaVar.getAUse() = problematicExpr.getAFlowNode() |
    not points_to_failure(ssaVar.getAnUltimateDefinition().getDefinition().getNode())
  ) and
  
  // The expression is not an assignment target
  not exists(Assign assignment | assignment.getATarget() = problematicExpr)
}

// Main query: Find attribute expressions with critical points-to failures
// that are not part of a call expression
from Attribute attrExpr
where 
  key_points_to_failure(attrExpr) and 
  not exists(Call funcCall | funcCall.getFunc() = attrExpr)
select attrExpr, "Expression does not 'point-to' any object, but all its sources do."