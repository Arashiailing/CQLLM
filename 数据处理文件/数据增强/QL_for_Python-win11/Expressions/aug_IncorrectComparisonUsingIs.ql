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

/** Holds if the comparison `comparison` uses `is` or `is not` (represented as `operator`) to compare its `leftOperand` and `rightOperand` arguments. */
predicate comparison_using_is(Compare comparison, ControlFlowNode leftOperand, Cmpop operator, ControlFlowNode rightOperand) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftOperand, operator, rightOperand) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Determines if an expression represents a value that is interned in CPython.
 * @param expr The expression to check.
 * @return true if the expression is a CPython-interned value, false otherwise.
 */
private predicate cpython_interned_value(Expr expr) {
  // Check for empty string or single-character ASCII strings
  exists(string text | text = expr.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integers in the range [-5, 256]
  or
  exists(int value | value = expr.(IntegerLiteral).getN().toInt() | -5 <= value and value <= 256)
  // Check for empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Determines if an expression represents a non-interned literal.
 * @param expr The expression to check.
 * @return true if the expression is a non-interned literal, false otherwise.
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literals
    or
    expr instanceof IntegerLiteral  // Integer literals
    or
    expr instanceof FloatLiteral  // Floating-point literals
    or
    expr instanceof Dict  // Dictionary literals
    or
    expr instanceof List  // List literals
    or
    expr instanceof Tuple  // Tuple literals
  ) and
  not cpython_interned_value(expr)  // Exclude CPython-interned values
}

from Compare comparison, Cmpop operator, string alternative
where
  exists(ControlFlowNode leftNode, ControlFlowNode rightNode |
    comparison_using_is(comparison, leftNode, operator, rightNode) and
    (
      operator instanceof Is and alternative = "=="
      or
      operator instanceof IsNot and alternative = "!="
    )
  |
    uninterned_literal(leftNode.getNode())  // Left operand is a non-interned literal
    or
    uninterned_literal(rightNode.getNode())  // Right operand is a non-interned literal
  )
select comparison,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternative + "' instead."