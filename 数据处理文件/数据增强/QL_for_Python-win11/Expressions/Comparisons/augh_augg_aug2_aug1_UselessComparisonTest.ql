/**
 * @name Redundant comparison
 * @description Identifies comparisons with predetermined outcomes due to prior conditional checks.
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
 * Determines if an expression contains chained comparison operators
 * (e.g., 'a < b < c' instead of simple binary comparisons).
 */
private predicate containsChainedComparisons(Expr expr) {
  // Check for expressions with multiple comparison operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively examine operands of unary expressions
  containsChainedComparisons(expr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a stricter condition
 * already governs the execution path.
 */
private predicate redundantComparisonDetected(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  // Exclude chained comparisons due to incomplete flow analysis
  not containsChainedComparisons(ctrlBlock.getTest().getNode())
}

private predicate locateRedundantComparison(AstNode currNode, AstNode prevNode, boolean outcome) {
  // Locate redundant comparisons through control flow analysis
  exists(Comparison cmpExpr, ConditionBlock condBlock |
    cmpExpr.getNode() = currNode and
    condBlock.getLastNode().getNode() = prevNode and
    redundantComparisonDetected(cmpExpr, condBlock, outcome)
  )
}

from Expr currentTest, Expr priorTest, boolean evalResult
where
  // Identify redundant tests while excluding nested redundant tests
  locateRedundantComparison(currentTest, priorTest, evalResult) and 
  not locateRedundantComparison(currentTest.getAChildNode+(), priorTest, _)
select currentTest, "Test is always " + evalResult + ", due to $@.", priorTest, "this condition"