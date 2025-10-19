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

// 检测在函数作用域外使用 return、yield 或 yield from 语句的情况
from AstNode problematicStatement, string statementType
where
  // 确保语句不在任何函数的作用域内
  not problematicStatement.getScope() instanceof Function
  and
  // 确定语句类型并检查是否为 return、yield 或 yield from
  (
    problematicStatement instanceof Return and statementType = "return"
    or
    problematicStatement instanceof Yield and statementType = "yield"
    or
    problematicStatement instanceof YieldFrom and statementType = "yield from"
  )
// 返回问题语句和相应的错误信息
select problematicStatement, "'" + statementType + "' is used outside a function."