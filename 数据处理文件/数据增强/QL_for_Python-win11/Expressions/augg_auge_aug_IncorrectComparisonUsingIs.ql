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
 * 判断比较表达式 `cmpExpr` 是否使用了 `is` 或 `is not` 操作符（由 `op` 表示）来比较其左右操作数（分别为 `leftOperand` 和 `rightOperand`）。
 */
predicate comparison_using_is(Compare cmpExpr, ControlFlowNode leftOperand, Cmpop op, ControlFlowNode rightOperand) {
  exists(CompareNode cmpFlowNode | cmpFlowNode = cmpExpr.getAFlowNode() |
    cmpFlowNode.operands(leftOperand, op, rightOperand) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * 判断表达式 `expr` 是否表示一个在 CPython 中被驻留（interned）的值。
 * 驻留值包括：空字符串、单字符ASCII字符串、范围[-5,256]内的整数、空元组。
 * @param expr 待检查的表达式。
 * @return 如果表达式是 CPython 驻留值，则返回 true，否则返回 false。
 */
private predicate cpython_interned_value(Expr expr) {
  // 检查空字符串或单字符 ASCII 字符串
  (exists(string strVal | strVal = expr.(StringLiteral).getText() |
    strVal.length() = 0
    or
    strVal.length() = 1 and strVal.regexpMatch("[U+0000-U+00ff]")
  )
  // 检查范围 [-5, 256] 内的整数
  or
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // 检查空元组
  or
  exists(Tuple tpl | tpl = expr and not exists(tpl.getAnElt())))
}

/**
 * 判断表达式 `expr` 是否表示一个非驻留的字面量。
 * 非驻留字面量包括：字符串、整数、浮点数、字典、列表、元组字面量，但不包括CPython驻留值。
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

from Compare cmpExpr, Cmpop op, ControlFlowNode leftOperand, ControlFlowNode rightOperand, string alternative
where
  comparison_using_is(cmpExpr, leftOperand, op, rightOperand) and
  (
    op instanceof Is and alternative = "=="
    or
    op instanceof IsNot and alternative = "!="
  ) and
  (
    uninterned_literal(leftOperand.getNode())  // 左操作数是非驻留字面量
    or
    uninterned_literal(rightOperand.getNode())  // 右操作数是非驻留字面量
  )
select cmpExpr,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternative + "' instead."