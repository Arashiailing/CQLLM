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

/** Holds if the comparison `comp` uses `is` or `is not` (represented as `op`) to compare its `left` and `right` arguments. */
predicate comparison_using_is(Compare comp, ControlFlowNode left, Cmpop op, ControlFlowNode right) {
  exists(CompareNode fcomp | fcomp = comp.getAFlowNode() |
    fcomp.operands(left, op, right) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief 判断表达式是否为CPython中会驻留（interned）的值。
 * @param e 要检查的表达式。
 * @return 如果表达式是CPython中会驻留的值，则返回true；否则返回false。
 */
private predicate cpython_interned_value(Expr e) {
  // 检查字符串字面量是否为空或单字符且在ASCII范围内。
  exists(string text | text = e.(StringLiteral).getText() |
    text.length() = 0
    or
    text.length() = 1 and text.regexpMatch("[U+0000-U+00ff]")
  )
  // 检查整数字面量是否在-5到256之间。
  or
  exists(int i | i = e.(IntegerLiteral).getN().toInt() | -5 <= i and i <= 256)
  // 检查元组是否为空。
  or
  exists(Tuple t | t = e and not exists(t.getAnElt()))
}

/**
 * @brief 判断表达式是否为未驻留的字面量。
 * @param e 要检查的表达式。
 * @return 如果表达式是未驻留的字面量，则返回true；否则返回false。
 */
predicate uninterned_literal(Expr e) {
  (
    e instanceof StringLiteral  // 检查是否为字符串字面量。
    or
    e instanceof IntegerLiteral  // 检查是否为整数字面量。
    or
    e instanceof FloatLiteral  // 检查是否为浮点数字面量。
    or
    e instanceof Dict  // 检查是否为字典。
    or
    e instanceof List  // 检查是否为列表。
    or
    e instanceof Tuple  // 检查是否为元组。
  ) and
  not cpython_interned_value(e)  // 并且不是CPython中会驻留的值。
}

from Compare comp, Cmpop op, string alt
where
  exists(ControlFlowNode left, ControlFlowNode right |
    comparison_using_is(comp, left, op, right) and
    (
      op instanceof Is and alt = "=="  // 如果操作符是`is`，建议使用`==`。
      or
      op instanceof IsNot and alt = "!="  // 如果操作符是`is not`，建议使用`!=`。
    )
  |
    uninterned_literal(left.getNode())  // 左操作数为未驻留的字面量。
    or
    uninterned_literal(right.getNode())  // 右操作数为未驻留的字面量。
  )
select comp,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alt + "' instead."
