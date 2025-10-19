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

/** Identifies comparisons using 'is'/'is not' operators between operands */
predicate comparison_using_is(Compare cmpNode, ControlFlowNode leftOp, Cmpop op, ControlFlowNode rightOp) {
  exists(CompareNode flowCmp | flowCmp = cmpNode.getAFlowNode() |
    flowCmp.operands(leftOp, op, rightOp) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief Checks if expression represents a CPython-interned value
 * @param expr Expression to evaluate
 * @return True for interned values in CPython
 */
private predicate cpython_interned_value(Expr expr) {
  // Empty/single-character ASCII strings
  exists(string strVal | strVal = expr.(StringLiteral).getText() |
    strVal.length() = 0
    or
    strVal.length() = 1 and strVal.regexpMatch("[U+0000-U+00ff]")
  )
  // Integers in [-5, 256] range
  or
  exists(int intVal | intVal = expr.(IntegerLiteral).getN().toInt() | -5 <= intVal and intVal <= 256)
  // Empty tuples
  or
  exists(Tuple t | t = expr and not exists(t.getAnElt()))
}

/**
 * @brief Identifies non-interned literal values
 * @param expr Expression to evaluate
 * @return True for non-interned literals
 */
predicate uninterned_literal(Expr expr) {
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
  not cpython_interned_value(expr)
}

from Compare cmpNode, Cmpop op, string altOp
where
  // Map operators to their equivalence alternatives
  (
    op instanceof Is and altOp = "=="
    or
    op instanceof IsNot and altOp = "!="
  ) and
  exists(ControlFlowNode leftOp, ControlFlowNode rightOp |
    comparison_using_is(cmpNode, leftOp, op, rightOp) and
    (
      uninterned_literal(leftOp.getNode())
      or
      uninterned_literal(rightOp.getNode())
    )
  )
select cmpNode,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + altOp + "' instead."