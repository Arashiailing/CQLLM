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

// 查找所有不在函数作用域内的 AST 节点
from AstNode problematicNode, string statementType
where
  // 确保节点不在任何函数的作用域内
  not problematicNode.getScope() instanceof Function and
  (
    // 检查节点是否为 return 语句
    (problematicNode instanceof Return and statementType = "return")
    or
    // 检查节点是否为 yield 语句
    (problematicNode instanceof Yield and statementType = "yield")
    or
    // 检查节点是否为 yield from 语句
    (problematicNode instanceof YieldFrom and statementType = "yield from")
  )
// 输出匹配的节点和相应的错误信息
select problematicNode, "'" + statementType + "' is used outside a function."