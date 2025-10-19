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
 * Determines if an expression is a complex comparison containing multiple operators
 * (e.g., chained comparisons like `a < b < c`), rather than a simple binary comparison.
 */
private predicate hasComplexForm(Expr expr) {
  // Check for chained comparisons (multiple operators)
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions
  hasComplexForm(expr.(UnaryExpr).getOperand())
}

/**
 * Identifies useless tests where a condition is always true/false due to a stricter
 * preceding condition that controls the same execution block.
 */
private predicate isUselessTest(Comparison comparison, ComparisonControlBlock controlledBlock, boolean outcome) {
  // Verify the block is controlled by a stricter condition
  controlledBlock.impliesThat(comparison.getBasicBlock(), comparison, outcome) and
  /* Exclude chained comparisons (e.g., `a < x < y`) due to incomplete flow analysis */
  not hasComplexForm(controlledBlock.getTest().getNode())
}

private predicate hasUselessTestAst(AstNode testNode, AstNode precedingNode, boolean outcome) {
  // Find all comparison nodes and condition blocks meeting the useless test criteria
  forex(Comparison comparison, ConditionBlock block |
    comparison.getNode() = testNode and
    block.getLastNode().getNode() = precedingNode
  |
    isUselessTest(comparison, block, outcome)
  )
}

from Expr testExpr, Expr precedingExpr, boolean outcome
where
  // Identify useless tests that aren't subsumed by child expressions
  hasUselessTestAst(testExpr, precedingExpr, outcome) and 
  not hasUselessTestAst(testExpr.getAChildNode+(), precedingExpr, _)
select testExpr, "Test is always " + outcome + ", because of $@.", precedingExpr, "this condition"