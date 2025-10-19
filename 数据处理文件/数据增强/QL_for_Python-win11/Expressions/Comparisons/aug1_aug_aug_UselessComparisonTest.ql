/**
 * @name Redundant comparison
 * @description Identifies comparisons whose outcomes are predetermined by preceding stricter conditions
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
 * Detects expressions with chained comparison operators (e.g., `a < x < y`)
 * rather than simple binary comparisons.
 */
private predicate containsMultipleOperators(Expr expr) {
  // Check for chained comparisons with multiple operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively examine operands within unary expressions
  containsMultipleOperators(expr.(UnaryExpr).getOperand())
}

/**
 * Finds comparisons whose results are implied by stricter controlling conditions
 * within the same execution block.
 */
private predicate hasRedundantComparison(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Verify the controlling block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  /* Exclude chained comparisons due to flow analysis limitations */
  not containsMultipleOperators(ctrlBlock.getTest().getNode())
}

/**
 * Maps test conditions to their controlling condition blocks
 * to identify redundant comparisons.
 */
private predicate mapsRedundantCondition(AstNode testNode, AstNode ctrlNode, boolean outcome) {
  // Connect comparison expressions to controlling condition blocks
  exists(Comparison cmp, ConditionBlock cBlock |
    cmp.getNode() = testNode and
    cBlock.getLastNode().getNode() = ctrlNode and
    hasRedundantComparison(cmp, cBlock, outcome)
  )
}

// Identify top-level redundant comparisons not nested within other redundant conditions
from Expr testExpr, Expr ctrlExpr, boolean outcome
where
  mapsRedundantCondition(testExpr, ctrlExpr, outcome) and 
  not mapsRedundantCondition(testExpr.getAChildNode+(), ctrlExpr, _)
select testExpr, "Test is always " + outcome + ", because of $@.", ctrlExpr, "this condition"