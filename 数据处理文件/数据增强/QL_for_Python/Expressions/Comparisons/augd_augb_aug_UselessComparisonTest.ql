/**
 * @name Redundant comparison
 * @description Identifies comparisons whose outcome is predetermined by preceding control flow conditions.
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
 * Determines if a comparison expression has a complex structure involving multiple operators.
 * This includes chained comparisons (e.g., 'a < x < y') or nested unary expressions.
 */
private predicate hasComplexStructure(Expr comparisonExpr) {
  // Check for multiple comparison operators (chained comparisons)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions for complexity
  hasComplexStructure(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a more restrictive condition already determines
 * the outcome in the same control block. Excludes complex chained comparisons due to
 * potential flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison comparisonNode, ComparisonControlBlock controlBlock, boolean evaluationResult) {
  // Control block implies the comparison result
  controlBlock.impliesThat(comparisonNode.getBasicBlock(), comparisonNode, evaluationResult) and
  // Exclude complex structures that might affect flow analysis accuracy
  not hasComplexStructure(controlBlock.getTest().getNode())
}

/**
 * Associates AST nodes containing redundant comparisons with their controlling conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode astNode, AstNode conditionNode, boolean evaluationResult) {
  exists(Comparison comparisonNode, ConditionBlock conditionBlock |
    // Map AST node to comparison node
    comparisonNode.getNode() = astNode and
    // Map condition to last node in condition block
    conditionBlock.getLastNode().getNode() = conditionNode and
    // Verify redundancy relationship
    isRedundantComparison(comparisonNode, conditionBlock, evaluationResult)
  )
}

from Expr testExpression, Expr relatedCondition, boolean evaluatesToTrue
where
  // Identify redundant tests excluding child nodes
  hasRedundantComparisonInAST(testExpression, relatedCondition, evaluatesToTrue) and 
  not hasRedundantComparisonInAST(testExpression.getAChildNode+(), relatedCondition, _)
select testExpression, "Test is always " + evaluatesToTrue + ", because of $@.", relatedCondition, "this condition"