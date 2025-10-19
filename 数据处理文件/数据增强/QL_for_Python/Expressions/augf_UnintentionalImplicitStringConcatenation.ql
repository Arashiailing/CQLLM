/**
 * @name Implicit string concatenation in a list
 * @description Detects when strings in a list are implicitly concatenated due to missing commas,
 *              which can lead to confusion and potential bugs.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       convention
 *       external/cwe/cwe-665
 * @problem.severity warning
 * @sub-severity high
 * @precision high
 * @id py/implicit-string-concatenation-in-list
 */

import python

// 判断表达式是否为字符串常量或由字符串常量隐式连接组成
predicate string_const(Expr expr) {
  // 基本情况：表达式是字符串字面量
  expr instanceof StringLiteral
  // 递归情况：表达式是二元操作，且左右操作数都是字符串常量
  or
  string_const(expr.(BinaryExpr).getLeft()) and string_const(expr.(BinaryExpr).getRight())
}

// 查找在列表中发生隐式字符串连接的情况
from StringLiteral strLiteral
where
  // 条件1：字符串位于一个包含至少两个字符串的列表中
  exists(List parentList, Expr anotherStr |
    // 确保当前字符串与另一个字符串不同
    not strLiteral = anotherStr and
    // 当前字符串是列表的元素
    parentList.getAnElt() = strLiteral and
    // 列表中还有另一个字符串
    parentList.getAnElt() = anotherStr and
    // 另一个字符串也是字符串常量
    string_const(anotherStr)
  ) and
  // 条件2：当前字符串存在隐式连接的部分
  exists(strLiteral.getAnImplicitlyConcatenatedPart()) and
  // 条件3：当前字符串没有被括号包围
  not strLiteral.isParenthesized()
select strLiteral, "Implicit string concatenation. Maybe missing a comma?"