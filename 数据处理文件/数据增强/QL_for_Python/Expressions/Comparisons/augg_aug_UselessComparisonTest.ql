/**
 * @name Redundant comparison
 * @description Identifies comparisons whose results are determined by preceding conditions
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
 * Checks if an expression has complex comparison structures including:
 * - Chained comparisons (e.g., a < b < c)
 * - Nested unary operations (e.g., not (x > y))
 */
private predicate hasComplexStructure(Expr expr) {
  // Detect chained comparisons with multiple operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively analyze unary expression operands
  hasComplexStructure(expr.(UnaryExpr).getOperand())
}

/**
 * Determines if a comparison is redundant by checking if its result
 * is implied by a controlling condition block. Excludes complex
 * comparison structures due to flow analysis limitations.
 */
private predicate isRedundantComparison(Comparison compNode, ComparisonControlBlock ctrlBlock, boolean resultValue) {
  // Verify control block implies comparison result
  ctrlBlock.impliesThat(compNode.getBasicBlock(), compNode, resultValue) and
  // Exclude complex comparison patterns
  not hasComplexStructure(ctrlBlock.getTest().getNode())
}

/**
 * Establishes relationship between redundant test expressions
 * and their corresponding controlling conditions in the AST.
 */
private predicate hasRedundantComparisonInAST(AstNode testNode, AstNode relatedCondNode, boolean resultValue) {
  forex(Comparison compNode, ConditionBlock condBlock |
    // Map test node to comparison node
    compNode.getNode() = testNode and
    // Map condition to last node in control block
    condBlock.getLastNode().getNode() = relatedCondNode
  |
    // Verify redundancy relationship
    isRedundantComparison(compNode, condBlock, resultValue)
  )
}

from Expr testExpr, Expr relatedCond, boolean resultValue
where
  // Identify redundant tests excluding child nodes
  hasRedundantComparisonInAST(testExpr, relatedCond, resultValue) and 
  not hasRedundantComparisonInAST(testExpr.getAChildNode+(), relatedCond, _)
select testExpr, "Test is always " + resultValue + ", because of $@.", relatedCond, "this condition"