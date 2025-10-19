/**
 * @name Redundant comparison
 * @description Identifies comparisons whose results are implied by previous conditions,
 *              indicating unnecessary or dead code paths.
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
 * Determines if a comparison expression has complex structural patterns,
 * such as chained comparisons (e.g., 'a < x < y') or nested unary operations.
 */
private predicate hasComplexStructure(Expr comparisonExpr) {
  // Check for chained comparisons (multiple operators)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions for complexity
  hasComplexStructure(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a controlling condition
 * already determines the comparison's outcome. Excludes complex
 * chained comparisons due to flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison comparisonNode, 
                                      ComparisonControlBlock controllingBlock, 
                                      boolean evaluationResult) {
  // The controlling block implies the comparison's result
  controllingBlock.impliesThat(comparisonNode.getBasicBlock(), 
                              comparisonNode, 
                              evaluationResult) and
  // Exclude complex chained comparisons (imprecise flow analysis)
  not hasComplexStructure(controllingBlock.getTest().getNode())
}

/**
 * Connects AST nodes containing redundant comparisons with their
 * associated controlling conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode redundantNode, 
                                            AstNode conditionNode, 
                                            boolean evaluationResult) {
  forex(Comparison comparisonNode, ConditionBlock conditionBlock |
    // The redundant node corresponds to a comparison
    comparisonNode.getNode() = redundantNode and
    // The condition node corresponds to the last node in a condition block
    conditionBlock.getLastNode().getNode() = conditionNode
  |
    // Verify the comparison is redundant
    isRedundantComparison(comparisonNode, conditionBlock, evaluationResult)
  )
}

from Expr redundantTestExpr, Expr relatedConditionExpr, boolean alwaysEvaluatesTo
where
  // Find redundant tests that aren't nested within other redundant tests
  hasRedundantComparisonInAST(redundantTestExpr, relatedConditionExpr, alwaysEvaluatesTo) and 
  not hasRedundantComparisonInAST(redundantTestExpr.getAChildNode+(), relatedConditionExpr, _)
select redundantTestExpr, 
       "Test is always " + alwaysEvaluatesTo + ", because of $@.", 
       relatedConditionExpr, 
       "this condition"