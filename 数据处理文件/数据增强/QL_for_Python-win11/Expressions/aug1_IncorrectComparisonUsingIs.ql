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

/** Holds if the comparison `comp` uses `is` or `is not` (represented as `op`) to compare its `left` and `right` arguments. */
predicate comparison_using_is(Compare comp, ControlFlowNode left, Cmpop op, ControlFlowNode right) {
  exists(CompareNode compareFlowNode | compareFlowNode = comp.getAFlowNode() |
    compareFlowNode.operands(left, op, right) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief Determines if the expression `e` is a value that is interned in CPython.
 * @param e The expression to check.
 * @return True if the expression is an interned value in CPython, false otherwise.
 */
private predicate cpython_interned_value(Expr e) {
  // Check for empty or single-character ASCII string literals
  exists(string text | text = e.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integer literals in the range [-5, 256]
  or
  exists(int intValue | intValue = e.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tupleNode | tupleNode = e and not exists(tupleNode.getAnElt()))
}

/**
 * @brief Determines if the expression `e` is a literal that is not interned.
 * @param e The expression to check.
 * @return True if the expression is a non-interned literal, false otherwise.
 */
predicate uninterned_literal(Expr e) {
  (
    e instanceof StringLiteral  // String literal
    or
    e instanceof IntegerLiteral  // Integer literal
    or
    e instanceof FloatLiteral  // Float literal
    or
    e instanceof Dict  // Dictionary literal
    or
    e instanceof List  // List literal
    or
    e instanceof Tuple  // Tuple literal
  ) and
  not cpython_interned_value(e)  // Not interned by CPython
}

from Compare comp, Cmpop op, string alt
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    comparison_using_is(comp, leftOperand, op, rightOperand) and
    (
      op instanceof Is and alt = "=="  // 'is' operator detected
      or
      op instanceof IsNot and alt = "!="  // 'is not' operator detected
    ) and
    (
      uninterned_literal(leftOperand.getNode())  // Left operand is non-interned literal
      or
      uninterned_literal(rightOperand.getNode())  // Right operand is non-interned literal
    )
  )
select comp,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alt + "' instead."