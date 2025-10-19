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
private predicate hasMultipleOperators(Expr expression) {
  // Check for chained comparisons with multiple operators
  exists(expression.(Compare).getOp(1))
  or
  // Recursively check operands within unary expressions
  hasMultipleOperators(expression.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant test conditions where a comparison's outcome is predetermined
 * by a stricter controlling condition within the same block.
 */
private predicate isRedundantComparison(Comparison comparisonExpr, ComparisonControlBlock controlBlock, boolean resultValue) {
  // Verify the block enforces a stricter condition that implies the comparison result
  controlBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, resultValue) and
  /* Exclude chained comparisons due to potential limitations in flow analysis */
  not hasMultipleOperators(controlBlock.getTest().getNode())
}

/**
 * Connects AST nodes to redundant comparisons by mapping test conditions
 * to their controlling condition blocks.
 */
private predicate hasRedundantTestCondition(AstNode conditionNode, AstNode controllingNode, boolean resultValue) {
  // Map comparison expressions to their controlling condition blocks
  exists(Comparison comparison, ConditionBlock condBlock |
    comparison.getNode() = conditionNode and
    condBlock.getLastNode().getNode() = controllingNode and
    isRedundantComparison(comparison, condBlock, resultValue)
  )
}

// Find redundant comparisons that aren't nested within other redundant comparisons
from Expr conditionExpr, Expr controllingExpr, boolean resultValue
where
  hasRedundantTestCondition(conditionExpr, controllingExpr, resultValue) and 
  not hasRedundantTestCondition(conditionExpr.getAChildNode+(), controllingExpr, _)
select conditionExpr, "Test is always " + resultValue + ", because of $@.", controllingExpr, "this condition"