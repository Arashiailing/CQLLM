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

/** Identifies comparisons using 'is' or 'is not' operators between operands */
predicate comparison_using_is(Compare comparisonExpr, ControlFlowNode leftExpr, Cmpop cmpOperator, ControlFlowNode rightExpr) {
  exists(CompareNode flowComparisonNode | flowComparisonNode = comparisonExpr.getAFlowNode() |
    flowComparisonNode.operands(leftExpr, cmpOperator, rightExpr) and
    (cmpOperator instanceof Is or cmpOperator instanceof IsNot)
  )
}

/**
 * @brief Checks if an expression represents a CPython-interned value
 * @param expr The expression to evaluate
 * @return True for values interned by CPython's runtime
 */
private predicate cpython_interned_value(Expr expr) {
  // Matches empty or single-character ASCII strings
  exists(string stringValue | stringValue = expr.(StringLiteral).getText() |
    stringValue.length() = 0
    or
    stringValue.length() = 1 and stringValue.regexpMatch("[U+0000-U+00ff]")
  )
  // Matches integers in CPython's cached range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Matches empty tuples
  or
  exists(Tuple tuple | tuple = expr and not exists(tuple.getAnElt()))
}

/**
 * @brief Identifies non-interned literal expressions
 * @param expr The expression to evaluate
 * @return True for literals not subject to CPython interning
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literals
    or
    expr instanceof IntegerLiteral  // Integer literals
    or
    expr instanceof FloatLiteral  // Float literals
    or
    expr instanceof Dict  // Dictionary literals
    or
    expr instanceof List  // List literals
    or
    expr instanceof Tuple  // Tuple literals
  ) and
  not cpython_interned_value(expr)  // Excludes CPython-interned values
}

from Compare comparisonExpr, Cmpop cmpOperator, string suggestedOperator
where
  exists(ControlFlowNode leftExpr, ControlFlowNode rightExpr |
    comparison_using_is(comparisonExpr, leftExpr, cmpOperator, rightExpr) and
    (
      cmpOperator instanceof Is and suggestedOperator = "=="  // 'is' → '=='
      or
      cmpOperator instanceof IsNot and suggestedOperator = "!="  // 'is not' → '!='
    )
  |
    uninterned_literal(leftExpr.getNode())  // Left operand is non-interned
    or
    uninterned_literal(rightExpr.getNode())  // Right operand is non-interned
  )
select comparisonExpr,
  "Values compared using '" + cmpOperator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + suggestedOperator + "' instead."