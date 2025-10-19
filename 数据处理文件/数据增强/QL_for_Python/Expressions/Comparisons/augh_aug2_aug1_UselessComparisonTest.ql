/**
 * @name Redundant comparison
 * @description Identifies comparisons that are redundant because their results are already determined by earlier conditions.
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
 * Determines if an expression contains chained comparison operators (e.g., 'a < b < c')
 * rather than a simple binary comparison.
 */
private predicate containsChainedOperators(Expr expression) {
  // Check for expressions with multiple comparison operators
  exists(expression.(Compare).getOp(1))
  or
  // Recursively examine operands of unary expressions
  containsChainedOperators(expression.(UnaryExpr).getOperand())
}

/**
 * Identifies comparisons that become redundant due to stricter conditions
 * established in preceding control blocks.
 */
private predicate isRedundantComparison(Comparison redundantCmp, ComparisonControlBlock controllingBlock, boolean outcome) {
  // Verify the controlling block enforces a stricter condition
  controllingBlock.impliesThat(redundantCmp.getBasicBlock(), redundantCmp, outcome) and
  /* Exclude chained comparisons due to incomplete flow analysis */
  // Skip expressions containing chained operators
  not containsChainedOperators(controllingBlock.getTest().getNode())
}

private predicate locatesRedundantComparison(AstNode currentNode, AstNode priorNode, boolean outcome) {
  // Find redundant comparisons by analyzing control flow relationships
  forex(Comparison redundantCmp, ConditionBlock condBlock |
    redundantCmp.getNode() = currentNode and
    condBlock.getLastNode().getNode() = priorNode
  |
    isRedundantComparison(redundantCmp, condBlock, outcome)
  )
}

from Expr currentExpr, Expr priorExpr, boolean evalResult
where
  // Identify redundant tests while excluding nested redundant tests
  locatesRedundantComparison(currentExpr, priorExpr, evalResult) and 
  not locatesRedundantComparison(currentExpr.getAChildNode+(), priorExpr, _)
select currentExpr, "Test is always " + evalResult + ", due to $@.", priorExpr, "this condition"