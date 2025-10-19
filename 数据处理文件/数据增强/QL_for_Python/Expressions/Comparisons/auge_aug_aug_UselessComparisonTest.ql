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

/**
 * Determines if a comparison expression contains multiple operators (e.g., chained comparisons like `a < x < y`)
 * rather than simple binary comparisons (e.g., `a < b`).
 */
private predicate hasMultipleOperators(Expr expr) {
  // Check for chained comparisons with multiple operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands within unary expressions
  hasMultipleOperators(expr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant test conditions where a comparison's outcome is predetermined
 * by a stricter controlling condition within the same block.
 */
private predicate isRedundantComparison(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean resVal) {
  // Verify the block enforces a stricter condition that implies the comparison result
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, resVal) and
  /* Exclude chained comparisons due to potential limitations in flow analysis */
  not hasMultipleOperators(ctrlBlock.getTest().getNode())
}

/**
 * Connects AST nodes to redundant comparisons by mapping test conditions
 * to their controlling condition blocks.
 */
private predicate hasRedundantTestCondition(AstNode condNode, AstNode ctrlNode, boolean resVal) {
  // Map comparison expressions to their controlling condition blocks
  exists(Comparison cmp, ConditionBlock condBlock |
    cmp.getNode() = condNode and
    condBlock.getLastNode().getNode() = ctrlNode and
    isRedundantComparison(cmp, condBlock, resVal)
  )
}

// Find redundant comparisons that aren't nested within other redundant comparisons
from Expr condExpr, Expr ctrlExpr, boolean resVal
where
  hasRedundantTestCondition(condExpr, ctrlExpr, resVal) and 
  not hasRedundantTestCondition(condExpr.getAChildNode+(), ctrlExpr, _)
select condExpr, "Test is always " + resVal + ", because of $@.", ctrlExpr, "this condition"