/**
 * @name Redundant comparison
 * @description Identifies comparisons whose outcome is predetermined by preceding control flow conditions.
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
 * Checks if an expression contains complex comparison structures.
 * This includes chained comparisons (e.g., 'a < x < y') or nested unary expressions.
 */
private predicate hasComplexComparisonStructure(Expr expressionToCheck) {
  // Detect chained comparisons with multiple operators
  exists(expressionToCheck.(Compare).getOp(1))
  or
  // Recursively check operand of unary expressions for complexity
  hasComplexComparisonStructure(expressionToCheck.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a more restrictive condition
 * in the same control block already determines the outcome. Excludes
 * complex chained comparisons to ensure analysis accuracy.
 */
private predicate isRedundantComparison(Comparison redundantComparison, ComparisonControlBlock controlBlock, boolean comparisonResult) {
  // Control block implies the comparison result
  controlBlock.impliesThat(redundantComparison.getBasicBlock(), redundantComparison, comparisonResult) and
  // Exclude complex expressions that could compromise analysis
  not hasComplexComparisonStructure(controlBlock.getTest().getNode())
}

/**
 * Establishes relationship between AST nodes containing redundant comparisons
 * and their corresponding controlling conditions.
 */
private predicate mapsRedundantComparisonToSource(AstNode redundantNode, AstNode determiningConditionNode, boolean comparisonResult) {
  exists(Comparison redundantComparison, ConditionBlock controllingBlock |
    // Link redundant node to comparison
    redundantComparison.getNode() = redundantNode and
    // Link condition to final node in controlling block
    controllingBlock.getLastNode().getNode() = determiningConditionNode and
    // Verify redundancy relationship
    isRedundantComparison(redundantComparison, controllingBlock, comparisonResult)
  )
}

from Expr redundantExpression, Expr determiningConditionExpr, boolean outcome
where
  // Find redundant tests excluding their child nodes
  mapsRedundantComparisonToSource(redundantExpression, determiningConditionExpr, outcome) and 
  not mapsRedundantComparisonToSource(redundantExpression.getAChildNode+(), determiningConditionExpr, _)
select redundantExpression, "Test is always " + outcome + ", because of $@.", determiningConditionExpr, "this condition"