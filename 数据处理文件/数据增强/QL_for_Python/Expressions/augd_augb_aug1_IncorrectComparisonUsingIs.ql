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

/** Identifies comparisons using 'is' or 'is not' operators */
predicate comparison_using_identity(Compare comparison, ControlFlowNode leftOperand, Cmpop op, ControlFlowNode rightOperand) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftOperand, op, rightOperand) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief Checks if expression is a CPython-interned value
 * @param expr Expression to evaluate
 * @return True for interned values (small integers, empty strings, etc.)
 */
private predicate is_interned_value(Expr expr) {
  // Empty or single-byte ASCII strings
  exists(string s | s = expr.(StringLiteral).getText() |
    s.length() = 0
    or
    s.length() = 1 and s.regexpMatch("[U+0000-U+00ff]")
  )
  // Integers in range [-5, 256]
  or
  exists(int n | n = expr.(IntegerLiteral).getN().toInt() | -5 <= n and n <= 256)
  // Empty tuples
  or
  exists(Tuple t | t = expr and not exists(t.getAnElt()))
}

/**
 * @brief Identifies non-interned literal values
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

from Compare comparison, Cmpop op, string suggestedOp
where
  exists(ControlFlowNode leftVal, ControlFlowNode rightVal |
    comparison_using_identity(comparison, leftVal, op, rightVal) and
    (
      op instanceof Is and suggestedOp = "=="
      or
      op instanceof IsNot and suggestedOp = "!="
    ) and
    (
      is_uninterned_literal(leftVal.getNode())
      or
      is_uninterned_literal(rightVal.getNode())
    )
  )
select comparison,
  "Identity comparison using '" + op.getSymbol() +
    "' where equivalence differs. Use '" + suggestedOp + "' instead."