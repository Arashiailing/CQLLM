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

// 查询目标：检测在函数体外使用控制流语句的情况
from AstNode problematicStmt, string statementType
where 
  // 确认语句不在任何函数定义的作用域内
  not exists(Function enclosingFunc | problematicStmt.getScope() = enclosingFunc.getScope())
  and
  (
    // 检测 return 语句
    (problematicStmt instanceof Return and statementType = "return")
    or
    // 检测 yield 语句
    (problematicStmt instanceof Yield and statementType = "yield")
    or
    // 检测 yield from 语句
    (problematicStmt instanceof YieldFrom and statementType = "yield from")
  )
// 返回违规语句及相应的错误描述
select problematicStmt, "'" + statementType + "' is used outside a function."