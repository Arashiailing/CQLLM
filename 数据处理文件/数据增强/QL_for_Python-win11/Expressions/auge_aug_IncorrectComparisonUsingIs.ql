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

/** 
 * 判断比较表达式 `comparison` 是否使用了 `is` 或 `is not` 操作符（由 `operator` 表示）来比较其左右操作数（分别为 `leftOpnd` 和 `rightOpnd`）。
 */
predicate comparison_using_is(Compare comparison, ControlFlowNode leftOpnd, Cmpop operator, ControlFlowNode rightOpnd) {
  exists(CompareNode cmpFlowNode | cmpFlowNode = comparison.getAFlowNode() |
    cmpFlowNode.operands(leftOpnd, operator, rightOpnd) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * 判断表达式 `expr` 是否表示一个在 CPython 中被驻留（interned）的值。
 * @param expr 待检查的表达式。
 * @return 如果表达式是 CPython 驻留值，则返回 true，否则返回 false。
 */
private predicate cpython_interned_value(Expr expr) {
  // 检查空字符串或单字符 ASCII 字符串
  exists(string strVal | strVal = expr.(StringLiteral).getText() |
    strVal.length() = 0
    or
    strVal.length() = 1 and strVal.regexpMatch("[U+0000-U+00ff]")
  )
  // 检查范围 [-5, 256] 内的整数
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // 检查空元组
  or
  exists(Tuple tpl | tpl = expr and not exists(tpl.getAnElt()))
}

/**
 * 判断表达式 `expr` 是否表示一个非驻留的字面量。
 * @param expr 待检查的表达式。
 * @return 如果表达式是非驻留字面量，则返回 true，否则返回 false。
 */
predicate uninterned_literal(Expr expr) {
  (
    expr instanceof StringLiteral  // 字符串字面量
    or
    expr instanceof IntegerLiteral  // 整数字面量
    or
    expr instanceof FloatLiteral  // 浮点数字面量
    or
    expr instanceof Dict  // 字典字面量
    or
    expr instanceof List  // 列表字面量
    or
    expr instanceof Tuple  // 元组字面量
  ) and
  not cpython_interned_value(expr)  // 排除 CPython 驻留值
}

from Compare comparison, Cmpop operator, ControlFlowNode leftOpnd, ControlFlowNode rightOpnd, string alternative
where
  comparison_using_is(comparison, leftOpnd, operator, rightOpnd) and
  (
    operator instanceof Is and alternative = "=="
    or
    operator instanceof IsNot and alternative = "!="
  ) and
  (
    uninterned_literal(leftOpnd.getNode())  // 左操作数是非驻留字面量
    or
    uninterned_literal(rightOpnd.getNode())  // 右操作数是非驻留字面量
  )
select comparison,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternative + "' instead."