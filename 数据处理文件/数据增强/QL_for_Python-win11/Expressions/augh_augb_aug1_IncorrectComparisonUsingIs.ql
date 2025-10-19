/**
 * @name Comparison using is when operands support `__eq__`
 * @description Detects potentially incorrect use of 'is' or 'is not' for value comparison
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Identifies comparisons using 'is' or 'is not' operators between two operands. */
predicate isComparisonUsed(Compare comparison, ControlFlowNode leftOperand, Cmpop cmpOperator, ControlFlowNode rightOperand) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftOperand, cmpOperator, rightOperand) and
    (cmpOperator instanceof Is or cmpOperator instanceof IsNot)
  )
}

/**
 * Checks if an expression represents a value that CPython interns.
 * @param expr The expression to evaluate.
 * @return True if the expression is an interned value in CPython.
 */
private predicate isInternedInCPython(Expr expr) {
  // Empty or single-character ASCII strings are interned
  exists(string strContent | strContent = expr.(StringLiteral).getText() |
    strContent.length() = 0
    or
    strContent.length() = 1 and strContent.regexpMatch("[U+0000-U+00ff]")
  )
  // Integers in range [-5, 256] are interned
  or
  exists(int intContent | intContent = expr.(IntegerLiteral).getN().toInt() | -5 <= intContent and intContent <= 256)
  // Empty tuples are interned
  or
  exists(Tuple emptyTuple | emptyTuple = expr and not exists(emptyTuple.getAnElt()))
}

/**
 * Determines if an expression is a literal that is not interned by CPython.
 * @param expr The expression to check.
 * @return True if the expression is a non-interned literal.
 */
predicate isNonInternedLiteral(Expr expr) {
  (expr instanceof StringLiteral or
   expr instanceof IntegerLiteral or
   expr instanceof FloatLiteral or
   expr instanceof Dict or
   expr instanceof List or
   expr instanceof Tuple) and
  not isInternedInCPython(expr)
}

from Compare comparison, Cmpop cmpOperator, string suggestedOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    isComparisonUsed(comparison, leftOperand, cmpOperator, rightOperand) and
    (
      (cmpOperator instanceof Is and suggestedOperator = "==") or
      (cmpOperator instanceof IsNot and suggestedOperator = "!=")
    ) and
    (
      isNonInternedLiteral(leftOperand.getNode()) or
      isNonInternedLiteral(rightOperand.getNode())
    )
  )
select comparison,
  "Values compared using '" + cmpOperator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + suggestedOperator + "' instead."