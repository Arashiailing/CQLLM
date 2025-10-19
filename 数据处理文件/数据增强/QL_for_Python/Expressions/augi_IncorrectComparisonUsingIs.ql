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

/** Determines if a comparison operation uses identity operators ('is'/'is not') */
predicate identity_comparison(Compare comp, ControlFlowNode leftOperand, Cmpop operator, ControlFlowNode rightOperand) {
  exists(CompareNode flowNode | flowNode = comp.getAFlowNode() |
    flowNode.operands(leftOperand, operator, rightOperand) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * Identifies expressions that are interned by CPython
 * @param expr The expression to evaluate
 * @return True if the expression is interned by CPython
 */
private predicate is_interned_value(Expr expr) {
  // Check for empty or single-byte ASCII strings
  exists(string strText | strText = expr.(StringLiteral).getText() |
    strText.length() = 0
    or
    strText.length() = 1 and strText.regexpMatch("[U+0000-U+00ff]")
  )
  // Check for integers in the cached range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * Identifies literal expressions that are not interned
 * @param expr The expression to evaluate
 * @return True if the expression is a non-interned literal
 */
predicate non_interned_literal(Expr expr) {
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

from Compare comp, Cmpop operator, string alternativeOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    identity_comparison(comp, leftOperand, operator, rightOperand) and
    (
      operator instanceof Is and alternativeOperator = "=="
      or
      operator instanceof IsNot and alternativeOperator = "!="
    )
  |
    non_interned_literal(leftOperand.getNode())
    or
    non_interned_literal(rightOperand.getNode())
  )
select comp,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternativeOperator + "' instead."