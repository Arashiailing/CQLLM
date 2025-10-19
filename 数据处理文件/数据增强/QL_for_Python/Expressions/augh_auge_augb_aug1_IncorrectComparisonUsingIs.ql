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

/** 当比较操作`comparison`使用`is`或`is not`（由`operator`表示）来比较其左操作数`leftOperand`和右操作数`rightOperand`时成立。 */
predicate isComparisonUsed(Compare comparison, ControlFlowNode leftOperand, Cmpop operator, ControlFlowNode rightOperand) {
  exists(CompareNode flowNode | flowNode = comparison.getAFlowNode() |
    flowNode.operands(leftOperand, operator, rightOperand) and
    (operator instanceof Is or operator instanceof IsNot)
  )
}

/**
 * @brief 判断表达式`expr`是否是CPython中驻留的值。
 * @param expr 要检查的表达式。
 * @return 如果表达式是CPython中驻留的值，则为true，否则为false。
 */
private predicate isInternedInCPython(Expr expr) {
  // 检查范围[-5, 256]内的整数字面量
  exists(int intValue | intValue = expr.(IntegerLiteral).getN().toInt() | -5 <= intValue and intValue <= 256)
  // 检查空字符串或单字符ASCII字符串字面量
  or
  exists(string strValue | strValue = expr.(StringLiteral).getText() |
    strValue.length() = 0
    or
    strValue.length() = 1 and strValue.regexpMatch("[U+0000-U+00ff]")
  )
  // 检查空元组
  or
  exists(Tuple tupleExpr | tupleExpr = expr and not exists(tupleExpr.getAnElt()))
}

/**
 * @brief 判断表达式`expr`是否是非驻留的字面量。
 * @param expr 要检查的表达式。
 * @return 如果表达式是非驻留的字面量，则为true，否则为false。
 */
predicate isNonInternedLiteral(Expr expr) {
  (
    expr instanceof StringLiteral   // 字符串字面量
    or
    expr instanceof IntegerLiteral  // 整数字面量
    or
    expr instanceof FloatLiteral    // 浮点数字面量
    or
    expr instanceof Dict            // 字典字面量
    or
    expr instanceof List            // 列表字面量
    or
    expr instanceof Tuple           // 元组字面量
  ) and
  not isInternedInCPython(expr)  // 不是由CPython驻留的
}

from Compare comparison, Cmpop operator, string alternativeOperator
where
  exists(ControlFlowNode leftOperand, ControlFlowNode rightOperand |
    isComparisonUsed(comparison, leftOperand, operator, rightOperand) and
    (
      operator instanceof Is and alternativeOperator = "=="      // 检测到'is'操作符
      or
      operator instanceof IsNot and alternativeOperator = "!="  // 检测到'is not'操作符
    ) and
    (
      isNonInternedLiteral(leftOperand.getNode())   // 左操作数是非驻留字面量
      or
      isNonInternedLiteral(rightOperand.getNode())  // 右操作数是非驻留字面量
    )
  )
select comparison,
  "Values compared using '" + operator.getSymbol() +
    "' when equivalence is not the same as identity. Use '" + alternativeOperator + "' instead."