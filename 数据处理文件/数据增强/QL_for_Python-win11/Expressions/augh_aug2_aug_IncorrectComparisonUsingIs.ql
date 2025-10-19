/**
 * @name Comparison using 'is' when operands support `__eq__`
 * @description Detects comparisons using 'is'/'is not' where equivalence differs from identity
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Identifies comparisons using 'is'/'is not' operators between specified operands */
predicate comparison_using_is(Compare comparison, ControlFlowNode leftNode, Cmpop operator, ControlFlowNode rightNode) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftNode, operator, rightNode) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Determines if an expression represents a CPython-interned value
 * @param expr The expression to evaluate
 * @return true if the expression is a CPython-interned value, false otherwise
 */
private predicate cpython_interned_value(Expr expr) {
  // Check for empty string or single-character ASCII strings
  exists(string strText | strText = expr.(StringLiteral).getText() |
    strText.length() = 0
    or
    strText.length() = 1 and strText.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integers in the range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Identifies non-interned literal expressions
 * @param expr The expression to evaluate
 * @return true if the expression is a non-interned literal, false otherwise
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