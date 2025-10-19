/**
 * @name Comparison using is when operands support `__eq__`
 * @description Detects comparisons using 'is'/'is not' when equivalence differs from identity
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Identifies comparisons using identity operators ('is'/'is not') between operands */
predicate identity_comparison(Compare comparison, ControlFlowNode leftNode, Cmpop operator, ControlFlowNode rightNode) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftNode, operator, rightNode) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Checks if expression represents CPython-interned values
 * @param expr Expression to evaluate
 * @return True for interned values (empty strings, small integers, empty tuples)
 */
private predicate is_interned_value(Expr expr) {
  // Empty or single-byte ASCII strings
  exists(string text | text = expr.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // Integers in CPython's cached range [-5, 256]
  or
  exists(int value | value = expr.(IntegerLiteral).getN().toInt() | -5 <= value and value <= 256)
  // Empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Identifies non-interned literal expressions
 * @param expr Expression to evaluate
 * @return True for literals not interned by CPython
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
  not is_interned_value(expr)
}

from Compare comparison, Cmpop operator, string replacement
where
  exists(ControlFlowNode leftNode, ControlFlowNode rightNode |
    identity_comparison(comparison, leftNode, operator, rightNode) and
    (
      operator instanceof Is and replacement = "=="
      or
      operator instanceof IsNot and replacement = "!="
    ) and
    (
      is_uninterned_literal(leftNode.getNode())
      or
      is_uninterned_literal(rightNode.getNode())
    )
  )
select comparison,
  "Identity comparison '" + operator.getSymbol() +
    "' used where equivalence differs from identity. Consider '" + replacement + "' instead."