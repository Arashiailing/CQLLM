/**
 * @name Redundant comparison
 * @description Detects comparisons whose outcomes are predetermined by prior conditional checks.
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
private predicate hasChainedComparisons(Expr targetExpr) {
  // Check for expressions with multiple comparison operators
  exists(targetExpr.(Compare).getOp(1))
  or
  // Recursively examine operands of unary expressions
  hasChainedComparisons(targetExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a stricter condition
 * already governs the execution path.
 */
private predicate redundantComparisonFound(Comparison comparisonExpr, ComparisonControlBlock controlBlock, boolean resultValue) {
  // Verify the control block enforces a stricter condition
  controlBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, resultValue) and
  /* Exclude chained comparisons due to incomplete flow analysis */
  // Skip expressions containing chained operators
  not hasChainedComparisons(controlBlock.getTest().getNode())
}

private predicate locateRedundantTest(AstNode currentNode, AstNode priorNode, boolean outcome) {
  // Identify redundant comparisons through control flow analysis
  forex(Comparison comparisonExpr, ConditionBlock conditionBlock |
    comparisonExpr.getNode() = currentNode and
    conditionBlock.getLastNode().getNode() = priorNode
  |
    redundantComparisonFound(comparisonExpr, conditionBlock, outcome)
  )
}

from Expr currentExpression, Expr priorExpression, boolean evaluationResult
where
  // Find redundant tests while excluding nested redundant comparisons
  locateRedundantTest(currentExpression, priorExpression, evaluationResult) and 
  not locateRedundantTest(currentExpression.getAChildNode+(), priorExpression, _)
select currentExpression, "Test is always " + evaluationResult + ", due to $@.", priorExpression, "this condition"