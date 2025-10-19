/**
 * @name Redundant comparison
 * @description The result of a comparison is implied by a previous comparison.
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
 * This includes chained comparisons like 'a < x < y' or nested unary expressions.
 */
private predicate hasComplexStructure(Expr comparisonExpr) {
  // Check if the comparison contains multiple operators (chained comparison)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check if the operand of a unary expression has complex structure
  hasComplexStructure(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies a test as useless when there exists a stricter condition that already
 * determines the control flow for the same block. Complex chained comparisons are excluded
 * due to limitations in flow analysis.
 */
private predicate isRedundantComparison(Comparison comparisonNode, ComparisonControlBlock controlBlock, boolean evaluatesToTrue) {
  // The control block implies the result of the comparison
  controlBlock.impliesThat(comparisonNode.getBasicBlock(), comparisonNode, evaluatesToTrue) and
  // Exclude complex chained comparisons as they may not have perfect flow analysis
  not hasComplexStructure(controlBlock.getTest().getNode())
}

/**
 * Connects AST nodes with redundant comparisons to their related conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode testNode, AstNode relatedConditionNode, boolean evaluatesToTrue) {
  forex(Comparison comparisonNode, ConditionBlock conditionBlock |
    // The test node corresponds to a comparison node
    comparisonNode.getNode() = testNode and
    // The related condition corresponds to the last node in a condition block
    conditionBlock.getLastNode().getNode() = relatedConditionNode
  |
    // Check if the comparison is redundant
    isRedundantComparison(comparisonNode, conditionBlock, evaluatesToTrue)
  )
}

from Expr testExpr, Expr relatedCondition, boolean evaluatesToTrue
where
  // Find useless tests, ensuring their child nodes are not also useless tests
  hasRedundantComparisonInAST(testExpr, relatedCondition, evaluatesToTrue) and 
  not hasRedundantComparisonInAST(testExpr.getAChildNode+(), relatedCondition, _)
select testExpr, "Test is always " + evaluatesToTrue + ", because of $@.", relatedCondition, "this condition"