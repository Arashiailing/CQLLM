/**
 * @name Redundant comparison
 * @description Detects comparisons whose outcomes are predetermined by preceding conditions.
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
 * Checks if a comparison expression uses chained operators (e.g., 'a < b < c')
 * instead of a simple binary comparison.
 */
private predicate hasComplexStructure(Expr expr) {
  // Identify expressions with multiple comparison operators
  exists(expr.(Compare).getOp(1))
  or
  // Recursively check operands of unary expressions for complexity
  hasComplexStructure(expr.(UnaryExpr).getOperand())
}

/**
 * Determines if a comparison is redundant when a stricter controlling condition exists
 * that governs the same execution paths.
 */
private predicate isUselessTest(Comparison cmpExpr, ComparisonControlBlock ctrlBlock, boolean evalResult) {
  // Verify the control block enforces a stricter condition
  ctrlBlock.impliesThat(cmpExpr.getBasicBlock(), cmpExpr, evalResult) and
  /* Exclude chained comparisons (e.g., 'a < x < y') due to incomplete flow analysis */
  not hasComplexStructure(ctrlBlock.getTest().getNode())
}

private predicate identifiesUselessTestInAST(AstNode testNode, AstNode prevNode, boolean evalResult) {
  // Traverse all comparison nodes and condition blocks to find redundant tests
  forex(Comparison cmpExpr, ConditionBlock condBlock |
    cmpExpr.getNode() = testNode and
    condBlock.getLastNode().getNode() = prevNode
  |
    isUselessTest(cmpExpr, condBlock, evalResult)
  )
}

from Expr redundantTest, Expr precedingCondition, boolean evalResult
where
  // Identify redundant tests while excluding child nodes that are also redundant
  identifiesUselessTestInAST(redundantTest, precedingCondition, evalResult) and 
  not identifiesUselessTestInAST(redundantTest.getAChildNode+(), precedingCondition, _)
select redundantTest, "Test is always " + evalResult + ", because of $@.", precedingCondition, "this condition"