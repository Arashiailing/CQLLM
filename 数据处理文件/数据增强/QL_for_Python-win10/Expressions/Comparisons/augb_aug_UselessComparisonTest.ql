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
 * Checks whether a comparison expression has a complicated structure that includes
 * multiple operators. This covers chained comparisons like 'a < x < y' or nested unary expressions.
 */
private predicate hasComplexStructure(Expr cmpExpr) {
  // Verify if the comparison contains multiple operators (chained comparison)
  exists(cmpExpr.(Compare).getOp(1))
  or
  // Recursively verify if the operand of a unary expression has complex structure
  hasComplexStructure(cmpExpr.(UnaryExpr).getOperand())
}

/**
 * Recognizes a test as redundant when there's a more restrictive condition that already
 * controls the flow for the same block. Complex chained comparisons are omitted
 * due to flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison cmpNode, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // The control block implies the result of the comparison
  ctrlBlock.impliesThat(cmpNode.getBasicBlock(), cmpNode, evalResult) and
  // Exclude complex chained comparisons as they may not have precise flow analysis
  not hasComplexStructure(ctrlBlock.getTest().getNode())
}

/**
 * Links AST nodes containing redundant comparisons with their associated conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode astNode, AstNode condNode, boolean evalResult) {
  forex(Comparison cmpNode, ConditionBlock condBlock |
    // The AST node corresponds to a comparison node
    cmpNode.getNode() = astNode and
    // The associated condition corresponds to the last node in a condition block
    condBlock.getLastNode().getNode() = condNode
  |
    // Verify if the comparison is redundant
    isRedundantComparison(cmpNode, condBlock, evalResult)
  )
}

from Expr testExpr, Expr relatedCondition, boolean evaluatesToTrue
where
  // Identify redundant tests, ensuring their child nodes are not also redundant
  hasRedundantComparisonInAST(testExpr, relatedCondition, evaluatesToTrue) and 
  not hasRedundantComparisonInAST(testExpr.getAChildNode+(), relatedCondition, _)
select testExpr, "Test is always " + evaluatesToTrue + ", because of $@.", relatedCondition, "this condition"