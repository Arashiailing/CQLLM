/**
 * @name Redundant comparison
 * @description Detects comparisons whose results are predetermined by earlier conditions.
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
 * Checks if an expression involves multiple comparison operators (e.g., chained comparisons like `a < x < y`)
 * as opposed to simple binary comparisons (e.g., `a < b`).
 */
private predicate containsMultipleOperators(Expr expr) {
  // Detect chained comparisons with more than one operator
  exists(expr.(Compare).getOp(1))
  or
  // Recursively examine operands within unary expressions
  containsMultipleOperators(expr.(UnaryExpr).getOperand())
}

/**
 * Finds test conditions that are redundant because their outcome is already determined
 * by a more restrictive controlling condition in the same code block.
 */
private predicate identifiesRedundantComparison(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean outcome) {
  // Ensure the block enforces a stricter condition that determines the comparison's result
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, outcome) and
  /* Exclude chained comparisons due to potential flow analysis limitations */
  not containsMultipleOperators(ctrlBlock.getTest().getNode())
}

/**
 * Links AST nodes to redundant comparisons by associating test conditions
 * with their controlling condition blocks.
 */
private predicate mapsRedundantCondition(AstNode testNode, AstNode ctrlNode, boolean outcome) {
  // Connect comparison expressions to their controlling condition blocks
  exists(Comparison cmp, ConditionBlock cBlock |
    cmp.getNode() = testNode and
    cBlock.getLastNode().getNode() = ctrlNode and
    identifiesRedundantComparison(cmp, cBlock, outcome)
  )
}

// Identify redundant comparisons that are not nested within other redundant comparisons
from Expr testCondition, Expr ctrlCondition, boolean outcome
where
  mapsRedundantCondition(testCondition, ctrlCondition, outcome) and 
  not mapsRedundantCondition(testCondition.getAChildNode+(), ctrlCondition, _)
select testCondition, "Test is always " + outcome + ", because of $@.", ctrlCondition, "this condition"