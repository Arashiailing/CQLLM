/**
 * @name Redundant comparison
 * @description Detects comparisons whose outcomes are predetermined by preceding conditions.
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
 * Identifies comparison expressions with chained operators (e.g., 'a < b < c')
 * instead of simple binary comparisons (e.g., 'a < b').
 */
private predicate hasChainedOperators(Expr cmpExpr) {
  // Check for multiple comparison operators in the expression
  exists(cmpExpr.(Compare).getOp(1))
  or
  // Recursively check unary expressions' operands
  hasChainedOperators(cmpExpr.(UnaryExpr).getOperand())
}

/**
 * A comparison is redundant if there exists a stricter controlling condition
 * that guarantees its outcome for all controlled blocks.
 */
private predicate isRedundantTest(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  /* Exclude chained comparisons like 'a < x < y' due to incomplete flow analysis */
  // Skip chained comparisons as flow analysis for these is not fully supported
  not hasChainedOperators(ctrlBlock.getTest().getNode())
}

private predicate redundantTestInAST(AstNode cmpNode, AstNode prevCond, boolean outcome) {
  // Find all comparison nodes and their controlling conditions
  exists(Comparison cmp, ComparisonControlBlock ctrlBlock |
    cmp.getNode() = cmpNode and
    ctrlBlock.getTest().getNode() = prevCond and
    isRedundantTest(cmp, ctrlBlock, outcome)
  )
}

from Expr testExpr, Expr prevCond, boolean outcome
where
  // Identify redundant tests while excluding their child nodes
  redundantTestInAST(testExpr, prevCond, outcome) and 
  not redundantTestInAST(testExpr.getAChildNode+(), prevCond, _)
select testExpr, "Test is always " + outcome + ", due to $@.", prevCond, "this condition"