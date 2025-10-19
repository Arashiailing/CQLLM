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

// 识别在函数作用域外误用的 return、yield 或 yield from 语句
from AstNode offendingNode, string keywordName
where
  // 确认该节点不在任何函数定义的作用域内
  not offendingNode.getScope() instanceof Function and
  // 检查节点是否为三种不允许在函数外使用的语句类型之一
  (
    offendingNode instanceof Return and keywordName = "return"
    or
    offendingNode instanceof Yield and keywordName = "yield"
    or
    offendingNode instanceof YieldFrom and keywordName = "yield from"
  )
// 报告问题节点和相应的错误描述
select offendingNode, "'" + keywordName + "' is used outside a function."