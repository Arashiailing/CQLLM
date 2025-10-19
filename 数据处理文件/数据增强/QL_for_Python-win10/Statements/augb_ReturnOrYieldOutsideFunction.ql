/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Using 'return' or 'yield' outside a function causes a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查找在函数作用域外使用的 return、yield 或 yield from 语句
from AstNode astNode, string statementType
where
  // 确保当前节点不在任何函数的作用域内
  not astNode.getScope() instanceof Function and
  // 检查节点类型并设置相应的语句类型
  (
    astNode instanceof Return and statementType = "return"
    or
    astNode instanceof Yield and statementType = "yield"
    or
    astNode instanceof YieldFrom and statementType = "yield from"
  )
// 输出检测结果和相应的错误信息
select astNode, "'" + statementType + "' is used outside a function."