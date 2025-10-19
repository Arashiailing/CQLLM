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

/*
 * Determines if a comparison expression has a complex structure such as 'a op b op c'
 * rather than a simple form 'a op b'.
 */
private predicate hasComplexStructure(Expr comparisonExpr) {
  // Check if the comparison contains multiple operators, indicating a complex form
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check if the operand of a unary expression has a complex structure
  hasComplexStructure(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies a test as useless if there exists another test that is at least as strict
 * and controls the same blocks.
 */
private predicate isUselessTest(Comparison comparisonExpr, ComparisonControlBlock controlBlock, boolean evaluationResult) {
  // Verify that the control block is governed by a more stringent test
  controlBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, evaluationResult) and
  /* Exclude complex comparisons like 'a < x < y', as current flow control analysis is incomplete for these */
  // Exclude complex-form comparisons due to imperfect flow control handling
  not hasComplexStructure(controlBlock.getTest().getNode())
}

private predicate identifiesUselessTestInAST(AstNode comparisonNode, AstNode precedingNode, boolean evaluationResult) {
  // Iterate through all qualifying comparison nodes and condition blocks to identify useless tests
  forex(Comparison comparisonExpr, ConditionBlock conditionBlock |
    comparisonExpr.getNode() = comparisonNode and
    conditionBlock.getLastNode().getNode() = precedingNode
  |
    isUselessTest(comparisonExpr, conditionBlock, evaluationResult)
  )
}

from Expr testExpr, Expr precedingExpr, boolean evaluationResult
where
  // Identify useless tests while ensuring their child nodes are not also useless tests
  identifiesUselessTestInAST(testExpr, precedingExpr, evaluationResult) and 
  not identifiesUselessTestInAST(testExpr.getAChildNode+(), precedingExpr, _)
select testExpr, "Test is always " + evaluationResult + ", because of $@.", precedingExpr, "this condition"