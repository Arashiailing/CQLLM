/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return' or 'yield' statements used outside function definitions,
 *              which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查询所有不在函数作用域内的 return/yield 语句
from AstNode astNode, string stmtType
where
  // 首先确保节点不在任何函数的作用域内
  not astNode.getScope() instanceof Function
  and (
    // 检查是否为 return 语句
    astNode instanceof Return and stmtType = "return"
    or
    // 检查是否为 yield 语句
    astNode instanceof Yield and stmtType = "yield"
    or
    // 检查是否为 yield from 语句
    astNode instanceof YieldFrom and stmtType = "yield from"
  )
// 输出违规节点及其对应的错误消息
select astNode, "'" + stmtType + "' is used outside a function."