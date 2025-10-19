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
private predicate hasChainedComparisons(Expr expression) {
  // Check for expressions with multiple comparison operators
  exists(expression.(Compare).getOp(1))
  or
  // Recursively examine operands of unary expressions
  hasChainedComparisons(expression.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a stricter condition
 * already governs the execution path.
 */
private predicate isRedundantComparison(Comparison comparisonExpr, ComparisonControlBlock controlBlock, boolean outcome) {
  // Verify the control block enforces a stricter condition
  controlBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, outcome) and
  // Exclude chained comparisons due to incomplete flow analysis
  not hasChainedComparisons(controlBlock.getTest().getNode())
}

private predicate findRedundantComparison(AstNode currentNode, AstNode priorNode, boolean outcome) {
  // Locate redundant comparisons through control flow analysis
  exists(Comparison comparisonExpr, ConditionBlock conditionBlock |
    comparisonExpr.getNode() = currentNode and
    conditionBlock.getLastNode().getNode() = priorNode and
    isRedundantComparison(comparisonExpr, conditionBlock, outcome)
  )
}

from Expr currentTest, Expr priorTest, boolean evalResult
where
  // Identify redundant tests while excluding nested redundant tests
  findRedundantComparison(currentTest, priorTest, evalResult) and 
  not findRedundantComparison(currentTest.getAChildNode+(), priorTest, _)
select currentTest, "Test is always " + evalResult + ", due to $@.", priorTest, "this condition"