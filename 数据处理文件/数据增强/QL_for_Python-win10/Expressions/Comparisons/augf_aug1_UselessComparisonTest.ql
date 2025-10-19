/**
 * @name Redundant comparison
 * @description Detects comparisons whose results are logically implied by previous comparisons.
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
 * Determines if a comparison expression has chained operators (e.g., 'a < b < c')
 * instead of a simple binary comparison (e.g., 'a < b').
 */
private predicate isComplexComparisonExpr(Expr expr) {
  // Check for multiple comparison operators in the expression
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operand of unary expressions for complexity
  isComplexComparisonExpr(expr.(UnaryExpr).getOperand())
}

/**
 * Identifies a test as redundant when another stricter test controls the same execution paths.
 */
private predicate isRedundantTest(Comparison testExpr, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(testExpr.getBasicBlock(), testExpr, evalResult) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete flow analysis */
  not isComplexComparisonExpr(ctrlBlock.getTest().getNode())
}

private predicate findsRedundantTestInAST(AstNode testNode, AstNode priorNode, boolean evalResult) {
  // Traverse all valid comparison nodes and condition blocks to find redundant tests
  forex(Comparison testExpr, ConditionBlock condBlock |
    testExpr.getNode() = testNode and
    condBlock.getLastNode().getNode() = priorNode
  |
    isRedundantTest(testExpr, condBlock, evalResult)
  )
}

from Expr testExpr, Expr precedingExpr, boolean evaluationResult
where
  // Identify redundant tests while excluding their child nodes from being redundant
  findsRedundantTestInAST(testExpr, precedingExpr, evaluationResult) and 
  not findsRedundantTestInAST(testExpr.getAChildNode+(), precedingExpr, _)
select testExpr, "Test is always " + evaluationResult + ", because of $@.", precedingExpr, "this condition"