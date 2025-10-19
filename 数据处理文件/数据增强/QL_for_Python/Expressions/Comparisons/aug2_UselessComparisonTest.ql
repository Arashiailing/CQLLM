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
 * Determines whether a comparison expression has a complex structure with multiple operators
 * (e.g., 'a op b op c') rather than a simple form (e.g., 'a op b').
 */
private predicate is_complex(Expr comparisonExpr) {
  // Check if the comparison expression contains multiple operators, indicating a complex form
  exists(comparisonExpr.(Compare).getOp(1))
  or
  // Recursively check if the operand of a unary expression is of complex form
  is_complex(comparisonExpr.(UnaryExpr).getOperand())
}

/**
 * A test condition is considered useless if, for every block it controls,
 * there exists another test condition that is at least as strict and also controls that block.
 */
private predicate useless_test(Comparison comparisonExpr, ComparisonControlBlock controllingBlock, boolean isTrue) {
  // Verify if the control block is governed by a more stringent test condition
  controllingBlock.impliesThat(comparisonExpr.getBasicBlock(), comparisonExpr, isTrue) and
  /* Exclude complex comparisons of form 'a < x < y', as we do not (yet) have perfect flow control for those */
  // Omit complex form comparisons since perfect flow control for these is not currently implemented
  not is_complex(controllingBlock.getTest().getNode())
}

private predicate useless_test_ast(AstNode comparisonNode, AstNode previousCondition, boolean isTrue) {
  // Iterate through all qualifying comparison nodes and condition blocks to identify useless tests
  forex(Comparison comparison, ConditionBlock conditionBlock |
    comparison.getNode() = comparisonNode and
    conditionBlock.getLastNode().getNode() = previousCondition
  |
    useless_test(comparison, conditionBlock, isTrue)
  )
}

from Expr testExpr, Expr previousCondition, boolean isTrue
where
  // Identify useless tests, ensuring their child nodes are not also useless tests
  useless_test_ast(testExpr, previousCondition, isTrue) and not useless_test_ast(testExpr.getAChildNode+(), previousCondition, _)
select testExpr, "Test is always " + isTrue + ", because of $@.", previousCondition, "this condition"