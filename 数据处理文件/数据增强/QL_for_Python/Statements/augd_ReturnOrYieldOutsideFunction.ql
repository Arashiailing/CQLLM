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

// 查找在函数作用域外使用 return 或 yield 相关语句的 AST 节点
from AstNode stmtNode, string stmtType
where
  // 确保节点不在任何函数的作用域内
  not stmtNode.getScope() instanceof Function and
  // 检查节点是否为 return、yield 或 yield from 语句
  (
    (stmtNode instanceof Return and stmtType = "return") or
    (stmtNode instanceof Yield and stmtType = "yield") or
    (stmtNode instanceof YieldFrom and stmtType = "yield from")
  )
// 输出问题节点和相应的错误信息
select stmtNode, "'" + stmtType + "' is used outside a function."