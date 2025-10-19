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

/**
 * Determines if an expression represents a CPython-interned value.
 * CPython interns specific values for optimization: empty strings, single ASCII characters,
 * integers in [-5, 256], and empty tuples.
 * @param expr The expression to evaluate
 * @return True if the expression is an interned value in CPython
 */
private predicate isInternedInCPython(Expr expr) {
  // Check for empty or single-character ASCII strings
  exists(string strValue | strValue = expr.(StringLiteral).getText() |
    strValue.length() = 0
    or
    (strValue.length() = 1 and strValue.regexpMatch("[\\x00-\\xFF]"))
  )
  // Check for integers in the interned range [-5, 256]
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // Check for empty tuples
  or
  exists(Tuple tupleExpr | tupleExpr = expr and not exists(tupleExpr.getAnElt()))
}

/**
 * Identifies expressions that are literals but not interned by CPython.
 * This includes non-interned strings, integers outside [-5, 256], floats,
 * and non-empty collections (dicts, lists, tuples).
 * @param expr The expression to check
 * @return True if the expression is a non-interned literal
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
  exists(ControlFlowNode leftNode, ControlFlowNode rightNode |
    // Directly access comparison operands through flow node
    exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
      flowNode.operands(leftNode, cmpOperator, rightNode) and
      (cmpOperator instanceof Is or cmpOperator instanceof IsNot)
    ) and
    // Determine the correct equality operator to suggest
    (
      (cmpOperator instanceof Is and suggestedOperator = "==") or
      (cmpOperator instanceof IsNot and suggestedOperator = "!=")
    ) and
    // Check if either operand is a non-interned literal
    (
      isNonInternedLiteral(leftNode.getNode()) or
      isNonInternedLiteral(rightNode.getNode())
    )
  )
select comparison,
  "Values compared using '" + cmpOperator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + suggestedOperator + "' instead."