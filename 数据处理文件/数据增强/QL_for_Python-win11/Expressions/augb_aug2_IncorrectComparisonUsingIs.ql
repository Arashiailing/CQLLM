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
predicate comparison_using_is(Compare cmpNode, ControlFlowNode leftOp, Cmpop op, ControlFlowNode rightOp) {
  exists(CompareNode flowCmpNode | flowCmpNode = cmpNode.getAFlowNode() |
    flowCmpNode.operands(leftOp, op, rightOp) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief Checks if an expression represents a CPython-interned value
 * @param expr Expression to evaluate
 * @return True for values that are interned in CPython
 */
private predicate cpython_interned_value(Expr expr) {
  // Empty or single-byte ASCII strings
  exists(string strVal | strVal = expr.(StringLiteral).getText() |
    strVal.length() = 0
    or
    strVal.length() = 1 and strVal.regexpMatch("[U+0000-U+00ff]")
  )
  // Small integers in CPython's interned range
  or
  exists(int intVal | intVal = expr.(IntegerLiteral).getN().toInt() | -5 <= intVal and intVal <= 256)
  // Empty tuples
  or
  exists(Tuple tpl | tpl = expr and not exists(tpl.getAnElt()))
}

/**
 * @brief Identifies literal values that are not interned by CPython
 * @param expr Expression to evaluate
 * @return True for non-interned literals
 */
predicate uninterned_literal(Expr expr) {
  (expr instanceof StringLiteral   // String literals
   or expr instanceof IntegerLiteral  // Integer literals
   or expr instanceof FloatLiteral    // Float literals
   or expr instanceof Dict            // Dictionaries
   or expr instanceof List            // Lists
   or expr instanceof Tuple)          // Tuples
  and not cpython_interned_value(expr)  // Exclude interned values
}

from Compare cmpNode, Cmpop op, string suggestedOp
where
  exists(ControlFlowNode leftOp, ControlFlowNode rightOp |
    comparison_using_is(cmpNode, leftOp, op, rightOp) and
    (op instanceof Is and suggestedOp = "=="   // Map 'is' to '=='
     or op instanceof IsNot and suggestedOp = "!=")  // Map 'is not' to '!='
    and
    (uninterned_literal(leftOp.getNode())   // Check left operand
     or uninterned_literal(rightOp.getNode()))  // Check right operand
  )
select cmpNode,
  "Comparison uses '" + op.getSymbol() +
    "' when equivalence differs from identity. Use '" + suggestedOp + "' instead."