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

/*
 * Determines if the given comparison expression is in complex form (e.g., `a op b op c`)
 * rather than simple form (e.g., `a op b`).
 */
private predicate is_complex(Expr comparisonExpr) {
  // Check if the comparison expression contains multiple operators (complex form)
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check if the operand of a unary expression is complex
  is_complex(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * Identifies a test as useless if for every block it controls, there exists another test
 * that is at least as strict and also controls that block.
 */
private predicate useless_test(Comparison testComparison, ComparisonControlBlock controllingBlock, boolean isTrue) {
  // Verify if the control block is governed by a more stringent test
  controllingBlock.impliesThat(testComparison.getBasicBlock(), testComparison, isTrue) and
  /* Exclude complex comparisons of form `a < x < y`, as we do not (yet) have perfect flow control for those */
  // Exclude complex form comparisons since perfect flow control is not currently implemented
  not is_complex(controllingBlock.getTest().getNode())
}

private predicate useless_test_ast(AstNode comparisonNode, AstNode relatedCondition, boolean isTrue) {
  // Iterate through all eligible comparison nodes and condition blocks to identify useless tests
  forex(Comparison currentComparison, ConditionBlock currentBlock |
    currentComparison.getNode() = comparisonNode and
    currentBlock.getLastNode().getNode() = relatedCondition
  |
    useless_test(currentComparison, currentBlock, isTrue)
  )
}

from Expr testExpr, Expr relatedCondition, boolean isTrue
where
  // Identify useless tests while ensuring their child nodes are not also useless tests
  useless_test_ast(testExpr, relatedCondition, isTrue) and not useless_test_ast(testExpr.getAChildNode+(), relatedCondition, _)
select testExpr, "Test is always " + isTrue + ", because of $@.", relatedCondition, "this condition"