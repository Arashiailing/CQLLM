/**
 * @name Comparison using is when operands support `__eq__`
 * @description Comparison using 'is' when equivalence is not the same as identity
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Holds if the comparison `comparisonNode` uses `is` or `is not` (represented as `operator`) to compare its `leftOperand` and `rightOperand` arguments. */
predicate comparison_using_is(Compare comparisonNode, ControlFlowNode leftOperand, Cmpop operator, ControlFlowNode rightOperand) {
  exists(CompareNode flowComparisonNode | flowComparisonNode = comparisonNode.getAFlowNode() |
    flowComparisonNode.operands(leftOperand, operator, rightOperand) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Determines if an expression represents a value that would be interned in CPython.
 * @param expr The expression to check.
 * @return True if the expression is an interned value in CPython, false otherwise.
 */
private predicate cpython_interned_value(Expr expr) {
  // Check for empty or single-character ASCII string literals
  exists(string stringValue | stringValue = expr.(StringLiteral).getText() |
    stringValue.length() = 0
    or
    stringValue.length() = 1 and stringValue.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integer literals in the range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Determines if an expression represents a non-interned literal value.
 * @param expr The expression to check.
 * @return True if the expression is a non-interned literal, false otherwise.
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literal check
    or
    expr instanceof IntegerLiteral  // Integer literal check
    or
    expr instanceof FloatLiteral  // Float literal check
    or
    expr instanceof Dict  // Dictionary check
    or
    expr instanceof List  // List check
    or
    expr instanceof Tuple  // Tuple check
  ) and
  not cpython_interned_value(expr)  // Excludes CPython-interned values
}

from Compare comparisonNode, Cmpop operator, string alternativeOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    comparison_using_is(comparisonNode, leftOperand, operator, rightOperand) and
    (
      operator instanceof Is and alternativeOperator = "=="  // Suggest '==' for 'is'
      or
      operator instanceof IsNot and alternativeOperator = "!="  // Suggest '!=' for 'is not'
    )
  |
    uninterned_literal(leftOperand.getNode())  // Left operand is non-interned literal
    or
    uninterned_literal(rightOperand.getNode())  // Right operand is non-interned literal
  )
select comparisonNode,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternativeOperator + "' instead."