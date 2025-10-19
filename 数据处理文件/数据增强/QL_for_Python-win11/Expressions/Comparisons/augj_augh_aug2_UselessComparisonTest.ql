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
private predicate contains_chained_ops(Expr targetExpr) {
  // Check for multiple comparison operators in a single expression
  exists(targetExpr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions
  contains_chained_ops(targetExpr.(UnaryExpr).getOperand())
}

/**
 * A test condition is redundant when a stricter preceding condition
 * guarantees its outcome for all controlled execution paths.
 */
private predicate is_comparison_redundant(Comparison comparisonExpr, ComparisonControlBlock controlBlock, boolean outcome) {
  // Verify if the control block enforces a stricter condition
  controlBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, outcome) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete
   * flow analysis for such constructs */
  not contains_chained_ops(controlBlock.getTest().getNode())
}

private predicate locate_redundant_test(AstNode testNode, AstNode priorCondition, boolean outcome) {
  // Map AST nodes to comparison objects and control blocks
  forex(Comparison cmp, ConditionBlock condBlock |
    cmp.getNode() = testNode and
    condBlock.getLastNode().getNode() = priorCondition
  |
    is_comparison_redundant(cmp, condBlock, outcome)
  )
}

from Expr currentTest, Expr priorCondition, boolean outcome
where
  // Identify redundant tests while excluding child nodes that are also redundant
  locate_redundant_test(currentTest, priorCondition, outcome) and 
  not locate_redundant_test(currentTest.getAChildNode+(), priorCondition, _)
select currentTest, "Test is always " + outcome + ", due to $@.", priorCondition, "preceding condition"