/**
 * @name Redundant comparison
 * @description Detects comparisons whose outcomes are predetermined by prior conditional checks.
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
 * Checks if a comparison expression uses chained operators (e.g., 'a < b < c')
 * instead of a simple binary comparison.
 */
private predicate containsChainedOperators(Expr expr) {
  // Identify expressions with multiple comparison operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions
  containsChainedOperators(expr.(UnaryExpr).getOperand())
}

/**
 * Determines if a comparison is redundant when a stricter condition
 * already controls the same execution path.
 */
private predicate isRedundantComparison(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  /* Exclude chained comparisons due to incomplete flow analysis */
  // Skip expressions with chained operators
  not containsChainedOperators(ctrlBlock.getTest().getNode())
}

private predicate locatesRedundantComparison(AstNode testNode, AstNode prevNode, boolean outcome) {
  // Find all redundant comparisons by examining control flow
  forex(Comparison cmpExpr, ConditionBlock condBlock |
    cmpExpr.getNode() = testNode and
    condBlock.getLastNode().getNode() = prevNode
  |
    isRedundantComparison(cmpExpr, condBlock, outcome)
  )
}

from Expr currentTest, Expr priorTest, boolean evalResult
where
  // Identify redundant tests while excluding nested redundant tests
  locatesRedundantComparison(currentTest, priorTest, evalResult) and 
  not locatesRedundantComparison(currentTest.getAChildNode+(), priorTest, _)
select currentTest, "Test is always " + evalResult + ", due to $@.", priorTest, "this condition"