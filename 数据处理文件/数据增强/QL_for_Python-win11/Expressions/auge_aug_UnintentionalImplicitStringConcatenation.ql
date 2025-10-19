/**
 * @name Implicit string concatenation in a list
 * @description Detects implicit string concatenation in lists which may indicate missing commas
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

// 谓词：识别字符串常量，包括隐式连接的字符串
predicate isStringConstant(Expr expr) {
  // 基本情况：直接字符串字面量
  expr instanceof StringLiteral
  // 递归情况：操作数为字符串常量的二元表达式
  or
  isStringConstant(expr.(BinaryExpr).getLeft()) and isStringConstant(expr.(BinaryExpr).getRight())
}

// 主查询：检测列表中的隐式字符串连接
from StringLiteral stringLiteral
where
  // 条件1：字符串位于包含其他字符串常量的列表中
  exists(List parentList |
    parentList.getAnElt() = stringLiteral and
    exists(Expr anotherString |
      not stringLiteral = anotherString and
      parentList.getAnElt() = anotherString and
      isStringConstant(anotherString)
    )
  ) and
  // 条件2：字符串具有隐式连接的组成部分
  exists(stringLiteral.getAnImplicitlyConcatenatedPart()) and
  // 条件3：字符串未被显式括号括起
  not stringLiteral.isParenthesized()
select stringLiteral, "Implicit string concatenation detected. Consider adding missing comma?"