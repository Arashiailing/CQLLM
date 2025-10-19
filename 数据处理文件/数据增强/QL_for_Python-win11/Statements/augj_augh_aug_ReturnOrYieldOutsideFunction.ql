/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Identifies 'return', 'yield', or 'yield from' statements that appear
 *              outside of function definitions, which would result in a 'SyntaxError'
 *              during program execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查找位于函数作用域之外的无效控制流语句
from AstNode invalidStmt, string stmtType
where 
  // 确保当前节点不包含在任何函数的作用域中
  not exists(Function parentFunction | invalidStmt.getScope() = parentFunction.getScope()) and
  (
    // 检测 return 语句
    invalidStmt instanceof Return and stmtType = "return"
    or
    // 检测 yield 语句
    invalidStmt instanceof Yield and stmtType = "yield"
    or
    // 检测 yield from 语句
    invalidStmt instanceof YieldFrom and stmtType = "yield from"
  )
// 报告发现的问题节点及对应的错误信息
select invalidStmt, "'" + stmtType + "' is used outside a function."