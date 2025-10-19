/**
 * @name Redundant comparison
 * @description Detects comparisons whose results are already determined by prior conditions.
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
 * Determines if a comparison expression has complex structure involving multiple operators.
 * This includes chained comparisons (e.g., 'a < x < y') or nested unary expressions.
 */
private predicate hasComplexStructure(Expr compExpr) {
  // Check for multiple comparison operators (chained comparison)
  exists(compExpr.(Compare).getOp(1))
  or
  // Recursively check operand of unary expressions for complexity
  hasComplexStructure(compExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies redundant comparisons where a stricter condition already determines control flow.
 * Excludes complex chained comparisons due to flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison compNode, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // Control block implies the comparison's outcome
  ctrlBlock.impliesThat(compNode.getBasicBlock(), compNode, evalResult) and
  // Exclude complex structures that may break flow analysis
  not hasComplexStructure(ctrlBlock.getTest().getNode())
}

/**
 * Connects AST nodes containing redundant comparisons to their determining conditions.
 */
private predicate hasRedundantComparisonInAST(AstNode testAstNode, AstNode relatedCondNode, boolean evalResult) {
  forex(Comparison compNode, ConditionBlock condBlock |
    // Map test AST node to comparison node
    compNode.getNode() = testAstNode and
    // Map related condition to last node in condition block
    condBlock.getLastNode().getNode() = relatedCondNode
  |
    // Verify redundancy of the comparison
    isRedundantComparison(compNode, condBlock, evalResult)
  )
}

from Expr testExp, Expr relatedCond, boolean evalResult
where
  // Identify useless tests excluding their child nodes
  hasRedundantComparisonInAST(testExp, relatedCond, evalResult) and 
  not hasRedundantComparisonInAST(testExp.getAChildNode+(), relatedCond, _)
select testExp, "Test is always " + evalResult + ", because of $@.", relatedCond, "this condition"