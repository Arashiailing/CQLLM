/**
 * @name Comparison using is when operands support `__eq__`
 * @description Identifies comparisons using 'is' or 'is not' where equivalence comparison would be more appropriate
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Holds if comparison `comp` uses `is`/`is not` (represented by `op`) between `leftOperand` and `rightOperand`. */
predicate comparison_using_is(Compare comp, ControlFlowNode leftOperand, Cmpop op, ControlFlowNode rightOperand) {
  exists(CompareNode fcomp | fcomp = comp.getAFlowNode() |
    fcomp.operands(leftOperand, op, rightOperand) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief Determines if expression represents a CPython-interned value.
 * @param expr Expression to evaluate.
 * @return true if expression represents an interned value (small integers, short strings, empty tuples).
 */
private predicate cpython_interned_value(Expr expr) {
  // Check for empty or single ASCII character strings
  exists(string text | text = expr.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integers in the interning range (-5 to 256)
  or
  exists(int i | i = expr.(IntegerLiteral).getN().toInt() | -5 <= i and i <= 256)
  // Check for empty tuples
  or
  exists(Tuple t | t = expr and not exists(t.getAnElt()))
}

/**
 * @brief Identifies expressions that are literals but not interned by CPython.
 * @param expr Expression to evaluate.
 * @return true if expression is a non-interned literal (strings, integers, floats, containers).
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
  not cpython_interned_value(expr)  // Exclude interned values
}

from Compare comp, Cmpop op, string recommendedOperator
where
  exists(ControlFlowNode leftNode, ControlFlowNode rightNode |
    comparison_using_is(comp, leftNode, op, rightNode) and
    (
      op instanceof Is and recommendedOperator = "=="  // 'is' should be '=='
      or
      op instanceof IsNot and recommendedOperator = "!="  // 'is not' should be '!='
    )
  |
    uninterned_literal(leftNode.getNode())  // Left operand is non-interned literal
    or
    uninterned_literal(rightNode.getNode())  // Right operand is non-interned literal
  )
select comp,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + recommendedOperator + "' instead."