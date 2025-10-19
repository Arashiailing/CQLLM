/**
 * @name Redundant comparison
 * @description Identifies comparisons whose results are logically implied by preceding conditions.
 * @kind problem
 * @tags useless-code
 *       external/cwe/cwe-561
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/redundant-comparison
 */

import python
import semmle.python.Comparisons

/**
 * Determines if a comparison expression has complex structure involving multiple operators.
 * This covers chained comparisons (e.g., 'a < x < y') and nested unary expressions.
 */
private predicate hasComplexStructure(Expr comparisonExpr) {
  // Check for multiple comparison operators (chained comparison)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions for complexity
  hasComplexStructure(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a more restrictive condition already controls flow.
 * Excludes complex chained comparisons due to flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison comparisonNode, ComparisonControlBlock controlBlock, boolean evaluationResult) {
  // Control block implies the comparison result
  controlBlock.impliesThat(comparisonNode.getBasicBlock(), comparisonNode, evaluationResult) and
  // Exclude complex structures with imprecise flow analysis
  not hasComplexStructure(controlBlock.getTest().getNode())
}

/**
 * Associates AST nodes containing redundant comparisons with their controlling conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode astNode, AstNode conditionNode, boolean evaluationResult) {
  exists(Comparison comparisonNode, ConditionBlock conditionBlock |
    // Map AST node to comparison node
    comparisonNode.getNode() = astNode and
    // Map condition node to control block's last node
    conditionBlock.getLastNode().getNode() = conditionNode and
    // Verify redundancy relationship
    isRedundantComparison(comparisonNode, conditionBlock, evaluationResult)
  )
}

from Expr testExpression, Expr relatedConditionExpr, boolean evaluatesTo
where
  // Find redundant tests excluding child nodes
  hasRedundantComparisonInAST(testExpression, relatedConditionExpr, evaluatesTo) and 
  not hasRedundantComparisonInAST(testExpression.getAChildNode+(), relatedConditionExpr, _)
select testExpression, "Test is always " + evaluatesTo + ", because of $@.", relatedConditionExpr, "this condition"