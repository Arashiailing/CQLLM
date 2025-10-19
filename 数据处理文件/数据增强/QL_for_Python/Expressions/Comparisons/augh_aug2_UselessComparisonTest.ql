/**
 * @name Redundant comparison
 * @description Identifies comparison expressions whose results are logically implied by preceding conditions.
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
 * (e.g., 'a < b < c') rather than simple binary comparisons.
 */
private predicate has_chained_ops(Expr expr) {
  // Check for multiple comparison operators in a single expression
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions
  has_chained_ops(expr.(UnaryExpr).getOperand())
}

/**
 * A test condition is redundant when a stricter preceding condition
 * guarantees its outcome for all controlled execution paths.
 */
private predicate redundant_test(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Verify if the control block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete
   * flow analysis for such constructs */
  not has_chained_ops(ctrlBlock.getTest().getNode())
}

private predicate redundant_test_in_ast(AstNode testNode, AstNode priorCond, boolean outcome) {
  // Map AST nodes to comparison objects and control blocks
  forex(Comparison cmp, ConditionBlock condBlock |
    cmp.getNode() = testNode and
    condBlock.getLastNode().getNode() = priorCond
  |
    redundant_test(cmp, condBlock, outcome)
  )
}

from Expr currentTest, Expr priorCond, boolean outcome
where
  // Identify redundant tests while excluding child nodes that are also redundant
  redundant_test_in_ast(currentTest, priorCond, outcome) and 
  not redundant_test_in_ast(currentTest.getAChildNode+(), priorCond, _)
select currentTest, "Test is always " + outcome + ", due to $@.", priorCond, "preceding condition"