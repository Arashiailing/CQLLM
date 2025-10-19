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
 * Checks if an expression has chained comparisons (e.g., 'a < b < c')
 * or nested unary operations that form complex structures.
 */
private predicate containsComplexComparison(Expr expr) {
  // Identify expressions with multiple comparison operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions for complexity
  containsComplexComparison(expr.(UnaryExpr).getOperand())
}

/**
 * Determines if a comparison is redundant due to a stricter condition
 * that controls the same execution blocks.
 */
private predicate isRedundantComparison(Comparison compExpr, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(compExpr.getBasicBlock(), compExpr, evalResult) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete
     flow analysis for such constructs */
  not containsComplexComparison(ctrlBlock.getTest().getNode())
}

private predicate findsRedundantComparison(AstNode testNode, AstNode prevNode, boolean evalResult) {
  // Search for redundant comparisons by examining all relevant
  // comparison expressions and condition blocks
  forex(Comparison compExpr, ConditionBlock condBlock |
    compExpr.getNode() = testNode and
    condBlock.getLastNode().getNode() = prevNode
  |
    isRedundantComparison(compExpr, condBlock, evalResult)
  )
}

from Expr redundantTestExpr, Expr prevConditionExpr, boolean evalResult
where
  // Identify redundant tests while excluding their child nodes
  // to avoid duplicate reporting of nested redundancies
  findsRedundantComparison(redundantTestExpr, prevConditionExpr, evalResult) and 
  not findsRedundantComparison(redundantTestExpr.getAChildNode+(), prevConditionExpr, _)
select redundantTestExpr, "Test is always " + evalResult + ", because of $@.", prevConditionExpr, "this condition"