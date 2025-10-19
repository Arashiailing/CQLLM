/**
 * @name Comparison using is when operands support `__eq__`
 * @description Detects usage of 'is' or 'is not' for comparing values where equivalence differs from identity
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** Identifies comparisons using 'is' or 'is not' operators between specified operands. */
predicate identity_comparison(Compare cmp, ControlFlowNode leftOp, Cmpop op, ControlFlowNode rightOp) {
  exists(CompareNode node | node = cmp.getAFlowNode() |
    node.operands(leftOp, op, rightOp) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * Determines if an expression represents a non-interned literal value.
 * Non-interned literals are values that aren't cached by Python's interpreter,
 * meaning identity checks ('is') may yield different results than equality checks ('==').
 */
predicate non_interned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // String literals
    or
    expr instanceof IntegerLiteral  // Integer literals
    or
    expr instanceof FloatLiteral  // Floating-point literals
    or
    expr instanceof Dict  // Dictionary literals
    or
    expr instanceof List  // List literals
    or
    expr instanceof Tuple  // Tuple literals
  ) and
  not (
    // Exclude CPython-interned values:
    // 1. Empty strings or single ASCII characters
    exists(string s | s = expr.(StringLiteral).getText() |
      s.length() = 0
      or
      s.length() = 1 and s.regexpMatch("[U+0000-U+00ff]")
    )
    // 2. Small integers [-5, 256]
    or
    exists(int val | val = expr.(IntegerLiteral).getN().toInt() | -5 <= val and val <= 256)
    // 3. Empty tuples
    or
    exists(Tuple t | t = expr and not exists(t.getAnElt()))
  )
}

from Compare cmp, Cmpop op, string altOp
where
  exists(ControlFlowNode left, ControlFlowNode right |
    identity_comparison(cmp, left, op, right) and
    (
      op instanceof Is and altOp = "=="
      or
      op instanceof IsNot and altOp = "!="
    )
  |
    non_interned_literal(left.getNode())  // Left operand is non-interned
    or
    non_interned_literal(right.getNode())  // Right operand is non-interned
  )
select cmp,
  "Comparison uses '" + op.getSymbol() +
    "' where equivalence differs from identity. Consider using '" + altOp + "' instead."