/**
 * @name Redundant comparison
 * @description Identifies comparisons whose outcome is determined by a preceding condition.
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
 * Determines if an expression represents a chained comparison (e.g., 'a < b < c')
 * or contains nested unary operations (e.g., 'not (a < b < c)').
 */
private predicate isComplexComparison(Expr comparisonExpr) {
  // Check for multiple comparison operators (chained comparisons)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check nested unary expressions
  isComplexComparison(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a stricter preceding condition
 * determines the comparison's outcome.
 */
private predicate isRedundantTest(Comparison redundantComparison, 
                                  ComparisonControlBlock controlBlock, 
                                  boolean evaluationResult) {
  // Verify the control block enforces a stricter condition
  controlBlock.impliesThat(redundantComparison.getBasicBlock(), 
                           redundantComparison, 
                           evaluationResult) and
  /* Exclude chained comparisons due to incomplete flow analysis */
  not isComplexComparison(controlBlock.getTest().getNode())
}

private predicate hasRedundantTestInAST(AstNode testNode, 
                                       AstNode priorNode, 
                                       boolean evaluationResult) {
  // Find comparison/control block pairs that satisfy redundancy conditions
  exists(Comparison candidateComparison, ConditionBlock candidateConditionBlock |
    candidateComparison.getNode() = testNode and
    candidateConditionBlock.getLastNode().getNode() = priorNode and
    isRedundantTest(candidateComparison, candidateConditionBlock, evaluationResult)
  )
}

from Expr redundantTest, Expr priorCondition, boolean evalResult
where
  // Identify top-level redundant tests (excluding nested redundant tests)
  hasRedundantTestInAST(redundantTest, priorCondition, evalResult) and 
  not hasRedundantTestInAST(redundantTest.getAChildNode+(), priorCondition, _)
select redundantTest, "Test is always " + evalResult + ", because of $@.", priorCondition, "this condition"