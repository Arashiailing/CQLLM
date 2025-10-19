/**
 * @name 使用'is'比较支持`__eq__`的操作数
 * @description 当等价性与同一性不同时，使用'is'进行比较
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity warning
 * @sub-severity low
 * @precision high
 * @id py/comparison-using-is
 */

import python

/** 当比较操作`comp`使用`is`或`is not`（由`op`表示）来比较其左操作数`left`和右操作数`right`时成立。 */
predicate isComparisonUsed(Compare comp, ControlFlowNode left, Cmpop op, ControlFlowNode right) {
  exists(CompareNode flowNode | flowNode = comp.getAFlowNode() |
    flowNode.operands(left, op, right) and
    (op instanceof Is or op instanceof IsNot)
  )
}

/**
 * @brief 判断表达式`e`是否是CPython中驻留的值。
 * @param e 要检查的表达式。
 * @return 如果表达式是CPython中驻留的值，则为true，否则为false。
 */
private predicate isInternedInCPython(Expr e) {
  // 检查空字符串或单字符ASCII字符串字面量
  exists(string s | s = e.(StringLiteral).getText() |
    s.length() = 0
    or
    s.length() = 1 and s.regexpMatch("[U+0000-U+00ff]")
  )
  // 检查范围[-5, 256]内的整数字面量
  or
  exists(int i | i = e.(IntegerLiteral).getN().toInt() | -5 <= i and i <= 256)
  // 检查空元组
  or
  exists(Tuple t | t = e and not exists(t.getAnElt()))
}

/**
 * @brief 判断表达式`e`是否是非驻留的字面量。
 * @param e 要检查的表达式。
 * @return 如果表达式是非驻留的字面量，则为true，否则为false。
 */
predicate isNonInternedLiteral(Expr e) {
  (
    e instanceof StringLiteral  // 字符串字面量
    or
    e instanceof IntegerLiteral  // 整数字面量
    or
    e instanceof FloatLiteral  // 浮点数字面量
    or
    e instanceof Dict  // 字典字面量
    or
    e instanceof List  // 列表字面量
    or
    e instanceof Tuple  // 元组字面量
  ) and
  not isInternedInCPython(e)  // 不是由CPython驻留的
}

from Compare comp, Cmpop op, string altOp
where
  exists(ControlFlowNode left, ControlFlowNode right |
    isComparisonUsed(comp, left, op, right) and
    (
      op instanceof Is and altOp = "=="  // 检测到'is'操作符
      or
      op instanceof IsNot and altOp = "!="  // 检测到'is not'操作符
    ) and
    (
      isNonInternedLiteral(left.getNode())  // 左操作数是非驻留字面量
      or
      isNonInternedLiteral(right.getNode())  // 右操作数是非驻留字面量
    )
  )
select comp,
  "Values compared using '" + op.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + altOp + "' instead."