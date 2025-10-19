/**
 * @name Redundant comparison
 * @description Identifies comparisons whose outcome is determined by a preceding condition.
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
 * Determines if a comparison expression uses chained operators (e.g., 'a < b < c')
 * rather than a simple binary comparison (e.g., 'a < b').
 */
private predicate isComplexComparison(Expr cmpExpr) {
  // Check for multiple comparison operators (chained comparisons)
  exists(cmpExpr.(Compare).getOp(1))
  or
  // Recursively check nested unary expressions (e.g., 'not (a < b < c)')
  isComplexComparison(cmpExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies a test as redundant when a stricter condition already controls
 * the same execution path.
 */
private predicate isRedundantTest(Comparison currentCmp, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(currentCmp.getBasicBlock(), currentCmp, evalResult) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete flow analysis */
  not isComplexComparison(ctrlBlock.getTest().getNode())
}

private predicate hasRedundantTestInAST(AstNode testNode, AstNode priorNode, boolean evalResult) {
  // Check all valid comparison/control block combinations for redundancy
  forex(Comparison cmpExpr, ConditionBlock condBlock |
    cmpExpr.getNode() = testNode and
    condBlock.getLastNode().getNode() = priorNode
  |
    isRedundantTest(cmpExpr, condBlock, evalResult)
  )
}

from Expr redundantTest, Expr priorCondition, boolean evalResult
where
  // Identify top-level redundant tests (excluding nested redundant tests)
  hasRedundantTestInAST(redundantTest, priorCondition, evalResult) and 
  not hasRedundantTestInAST(redundantTest.getAChildNode+(), priorCondition, _)
select redundantTest, "Test is always " + evalResult + ", because of $@.", priorCondition, "this condition"