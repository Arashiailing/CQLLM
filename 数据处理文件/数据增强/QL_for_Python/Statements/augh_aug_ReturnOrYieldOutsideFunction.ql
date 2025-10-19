/**
 * @name Use of 'return' or 'yield' outside a function
 * @description Detects 'return' or 'yield' statements that are used outside of function definitions,
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

// 查找不在函数作用域内的特定语句类型
from AstNode problematicNode, string statementType
where 
  // 确认当前节点不在任何函数的作用域内
  not exists(Function enclosingFunction | problematicNode.getScope() = enclosingFunction.getScope()) and
  (
    // 识别 return 语句
    problematicNode instanceof Return and statementType = "return"
    or
    // 识别 yield 语句
    problematicNode instanceof Yield and statementType = "yield"
    or
    // 识别 yield from 语句
    problematicNode instanceof YieldFrom and statementType = "yield from"
  )
// 输出检测到的问题节点及相应的错误描述
select problematicNode, "'" + statementType + "' is used outside a function."