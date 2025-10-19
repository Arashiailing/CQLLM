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
 * Determines if an expression contains complex comparison structures.
 * This includes chained comparisons (e.g., 'a < x < y') or nested unary expressions.
 */
private predicate containsComplexComparison(Expr exprToCheck) {
  // Check for chained comparisons with multiple operators
  exists(exprToCheck.(Compare).getOp(1))
  or
  // Recursively check if operand of unary expression contains complexity
  containsComplexComparison(exprToCheck.(UnaryExpr).getOperand())
}

/**
 * Identifies comparisons that are redundant because a more restrictive condition
 * in the same control block already determines their outcome. Excludes complex
 * chained comparisons to maintain analysis accuracy.
 */
private predicate representsRedundantComparison(Comparison redundantCmp, ComparisonControlBlock ctrlBlock, boolean resultValue) {
  // Control block logically implies the comparison result
  ctrlBlock.impliesThat(redundantCmp.getBasicBlock(), redundantCmp, resultValue) and
  // Exclude expressions with complex structures that could compromise analysis
  not containsComplexComparison(ctrlBlock.getTest().getNode())
}

/**
 * Establishes relationship between AST nodes containing redundant comparisons
 * and their corresponding controlling conditions.
 */
private predicate linksRedundantComparisonToSource(AstNode targetNode, AstNode sourceCondition, boolean resultValue) {
  exists(Comparison redundantCmp, ConditionBlock conditionBlock |
    // Connect target node to the redundant comparison
    redundantCmp.getNode() = targetNode and
    // Connect source condition to the final node in condition block
    conditionBlock.getLastNode().getNode() = sourceCondition and
    // Verify the redundancy relationship
    representsRedundantComparison(redundantCmp, conditionBlock, resultValue)
  )
}

from Expr redundantExpr, Expr determiningCondition, boolean fixedOutcome
where
  // Find redundant tests while excluding their child nodes
  linksRedundantComparisonToSource(redundantExpr, determiningCondition, fixedOutcome) and 
  not linksRedundantComparisonToSource(redundantExpr.getAChildNode+(), determiningCondition, _)
select redundantExpr, "Test is always " + fixedOutcome + ", because of $@.", determiningCondition, "this condition"