/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description The Python language requires 'return', 'yield', and 'yield from' statements
 *              to be used exclusively within function definitions. Using these statements
 *              in any other context results in a SyntaxError during program execution.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查找在非函数作用域中使用的 return、yield 或 yield from 语句
from AstNode problematicNode, string statementType
where
  // 验证该节点的作用域不是函数定义
  not problematicNode.getScope() instanceof Function
  and
  // 确定节点类型并设置相应的语句类型描述
  (
    problematicNode instanceof Return and statementType = "return"
    or
    problematicNode instanceof Yield and statementType = "yield"
    or
    problematicNode instanceof YieldFrom and statementType = "yield from"
  )
// 输出检测结果和对应的错误信息
select problematicNode, "'" + statementType + "' is used outside a function."