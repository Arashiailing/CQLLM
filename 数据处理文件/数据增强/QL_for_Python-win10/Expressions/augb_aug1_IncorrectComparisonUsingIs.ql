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

/** Holds if the comparison `comparison` uses `is` or `is not` (represented as `operator`) to compare its `leftNode` and `rightNode` arguments. */
predicate comparison_using_is(Compare comparison, ControlFlowNode leftNode, Cmpop operator, ControlFlowNode rightNode) {
  exists(CompareNode compareFlowNode | compareFlowNode = comparison.getAFlowNode() |
    compareFlowNode.operands(leftNode, operator, rightNode) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Determines if the expression `expr` is a value that is interned in CPython.
 * @param expr The expression to check.
 * @return True if the expression is an interned value in CPython, false otherwise.
 */
private predicate cpython_interned_value(Expr expr) {
  // Check for empty or single-character ASCII string literals
  exists(string strValue | strValue = expr.(StringLiteral).getText() |
    strValue.length() = 0
    or
    strValue.length() = 1 and strValue.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integer literals in the range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tupleNode | tupleNode = expr and not exists(tupleNode.getAnElt()))
}

/**
 * @brief Determines if the expression `expr` is a literal that is not interned.
 * @param expr The expression to check.
 * @return True if the expression is a non-interned literal, false otherwise.
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literal
    or
    expr instanceof IntegerLiteral  // Integer literal
    or
    expr instanceof FloatLiteral  // Float literal
    or
    expr instanceof Dict  // Dictionary literal
    or
    expr instanceof List  // List literal
    or
    expr instanceof Tuple  // Tuple literal
  ) and
  not cpython_interned_value(expr)  // Not interned by CPython
}

from Compare comparison, Cmpop operator, string alternativeOperator
where
  exists(ControlFlowNode leftNode, ControlFlowNode rightNode |
    comparison_using_is(comparison, leftNode, operator, rightNode) and
    (
      operator instanceof Is and alternativeOperator = "=="  // 'is' operator detected
      or
      operator instanceof IsNot and alternativeOperator = "!="  // 'is not' operator detected
    ) and
    (
      uninterned_literal(leftNode.getNode())  // Left operand is non-interned literal
      or
      uninterned_literal(rightNode.getNode())  // Right operand is non-interned literal
    )
  )
select comparison,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternativeOperator + "' instead."