/**
 * @name Comparison using is when operands support `__eq__`
 * @description Detects 'is' comparisons where equivalence differs from identity
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Identifies comparisons using 'is' or 'is not' operators between operands. */
predicate comparison_using_identity(Compare identityComparison, ControlFlowNode leftSide, Cmpop identityOperator, ControlFlowNode rightSide) {
  exists(CompareNode flowNode | flowNode = identityComparison.getAFlowNode() |
    flowNode.operands(leftSide, identityOperator, rightSide) and
    (identityOperator instanceof Is or identityOperator instanceof IsNot)
  )
}

/**
 * @brief Determines if an expression represents a CPython-interned value.
 * @param expr Expression to evaluate
 * @return true if expression is an interned value in CPython
 */
private predicate is_cpython_interned(Expr expr) {
  // Empty strings or single ASCII characters are interned
  exists(string text | text = expr.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // Integers between -5 and 256 are interned
  or
  exists(int value | value = expr.(IntegerLiteral).getN().toInt() | -5 <= value and value <= 256)
  // Empty tuples are interned
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Identifies non-interned literal expressions.
 * @param expr Expression to evaluate
 * @return true if expression is a non-interned literal
 */
predicate is_uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral
    or
    expr instanceof IntegerLiteral
    or
    expr instanceof FloatLiteral
    or
    expr instanceof Dict
    or
    expr instanceof List
    or
    expr instanceof Tuple
  ) and
  not is_cpython_interned(expr)
}

from Compare identityComparison, Cmpop identityOperator, string suggestedOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    comparison_using_identity(identityComparison, leftOperand, identityOperator, rightOperand) and
    (
      identityOperator instanceof Is and suggestedOperator = "=="
      or
      identityOperator instanceof IsNot and suggestedOperator = "!="
    )
  |
    is_uninterned_literal(leftOperand.getNode())
    or
    is_uninterned_literal(rightOperand.getNode())
  )
select identityComparison,
  "Values compared using '" + identityOperator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + suggestedOperator + "' instead."