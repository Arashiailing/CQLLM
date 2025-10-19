/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description This query identifies instances where 'return', 'yield', or 'yield from' statements
 *              are placed outside of a function definition. Such usage will result in a 'SyntaxError'
 *              when the Python code is executed, as these statements are only valid within function bodies.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 定义查询变量：targetNode 表示目标 AST 节点，nodeType 表示节点的类型字符串
from AstNode targetNode, string nodeType
where
  // 检查节点是否为 return、yield 或 yield from 语句，并设置对应的类型字符串
  (
    targetNode instanceof Return and nodeType = "return"
    or
    targetNode instanceof Yield and nodeType = "yield"
    or
    targetNode instanceof YieldFrom and nodeType = "yield from"
  ) and
  // 验证该语句节点不在任何函数的作用域内
  not targetNode.getScope() instanceof Function
// 选择符合条件的语句节点，并生成描述问题的警告信息
select targetNode, "Statement '" + nodeType + "' is used outside a function definition."