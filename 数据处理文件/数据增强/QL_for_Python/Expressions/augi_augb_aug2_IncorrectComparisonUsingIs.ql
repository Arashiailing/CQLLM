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

/** Identifies comparisons using 'is' or 'is not' operators between operands */
predicate comparison_using_is(Compare cmp, ControlFlowNode leftOperand, Cmpop operator, ControlFlowNode rightOperand) {
  exists(CompareNode flowCmp | flowCmp = cmp.getAFlowNode() |
    flowCmp.operands(leftOperand, operator, rightOperand) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief Determines if an expression represents a CPython-interned value
 * @param expression Expression to evaluate
 * @return True for values that are interned in CPython
 */
private predicate cpython_interned_value(Expr expression) {
  // Empty or single-byte ASCII strings
  exists(string stringValue | stringValue = expression.(StringLiteral).getText() |
    stringValue.length() = 0
    or
    stringValue.length() = 1 and stringValue.regexpMatch("[U+0000-U+00ff]")
  )
  // Small integers in CPython's interned range
  or
  exists(int integerValue | integerValue = expression.(IntegerLiteral).getN().toInt() | -5 <= integerValue and integerValue <= 256)
  // Empty tuples
  or
  exists(Tuple tuple | tuple = expression and not exists(tuple.getAnElt()))
}

/**
 * @brief Identifies literal values that are not interned by CPython
 * @param expression Expression to evaluate
 * @return True for non-interned literals
 */
predicate uninterned_literal(Expr expression) {
  (expression instanceof StringLiteral   // String literals
   or expression instanceof IntegerLiteral  // Integer literals
   or expression instanceof FloatLiteral    // Float literals
   or expression instanceof Dict            // Dictionaries
   or expression instanceof List            // Lists
   or expression instanceof Tuple)          // Tuples
  and not cpython_interned_value(expression)  // Exclude interned values
}

from Compare cmp, Cmpop operator, string suggestedOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    comparison_using_is(cmp, leftOperand, operator, rightOperand) and
    // Map identity operators to equivalence operators
    (operator instanceof Is and suggestedOperator = "=="
     or operator instanceof IsNot and suggestedOperator = "!=")
    and
    // Check if either operand is a non-interned literal
    (uninterned_literal(leftOperand.getNode())
     or uninterned_literal(rightOperand.getNode()))
  )
select cmp,
  "Comparison uses '" + operator.getSymbol() +
    "' when equivalence differs from identity. Use '" + suggestedOperator + "' instead."