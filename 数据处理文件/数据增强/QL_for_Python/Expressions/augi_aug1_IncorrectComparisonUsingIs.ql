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

/** Identifies comparisons using 'is' or 'is not' operators between operands. */
predicate comparison_using_is(Compare comparison, ControlFlowNode leftNode, Cmpop operator, ControlFlowNode rightNode) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftNode, operator, rightNode) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Checks if an expression represents a CPython-interned value.
 * @param expr The expression to evaluate.
 * @return True if the expression is a CPython-interned value, false otherwise.
 */
private predicate cpython_interned_value(Expr expr) {
  // Match empty or single-character ASCII string literals
  exists(string literalText | literalText = expr.(StringLiteral).getText() |
    literalText.length() = 0
    or
    literalText.length() = 1 and literalText.regexpMatch("[U+0000-U+00ff]")
  )
  // Match integer literals in the range [-5, 256]
  or
  exists(int literalValue | literalValue = expr.(IntegerLiteral).getN().toInt() | -5 <= literalValue and literalValue <= 256)
  // Match empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Determines if an expression is a non-interned literal.
 * @param expr The expression to evaluate.
 * @return True if the expression is a non-interned literal, false otherwise.
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literal
    or
    expr instanceof IntegerLiteral  // Integer literal
    or
    expr instanceof FloatLiteral   // Float literal
    or
    expr instanceof Dict           // Dictionary literal
    or
    expr instanceof List           // List literal
    or
    expr instanceof Tuple          // Tuple literal
  ) and
  not cpython_interned_value(expr)  // Exclude CPython-interned values
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