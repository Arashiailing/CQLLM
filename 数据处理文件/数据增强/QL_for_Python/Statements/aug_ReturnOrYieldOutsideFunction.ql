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

// 定义查询目标：查找不在函数作用域内的特定语句
from AstNode stmt, string stmtType
where 
  // 确保语句不在任何函数的作用域内
  not exists(Function func | stmt.getScope() = func.getScope()) and
  (
    // 匹配 return 语句并设置类型标识
    stmt instanceof Return and stmtType = "return"
    or
    // 匹配 yield 语句并设置类型标识
    stmt instanceof Yield and stmtType = "yield"
    or
    // 匹配 yield from 语句并设置类型标识
    stmt instanceof YieldFrom and stmtType = "yield from"
  )
// 输出违规语句节点及对应的错误信息
select stmt, "'" + stmtType + "' is used outside a function."