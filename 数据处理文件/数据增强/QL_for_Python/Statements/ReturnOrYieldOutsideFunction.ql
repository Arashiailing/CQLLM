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

// 从抽象语法树节点和字符串类型中导入数据
from AstNode node, string kind
where
  // 检查节点是否不在函数的作用域内
  not node.getScope() instanceof Function and
  (
    // 检查节点是否是 return 语句，并且类型是 "return"
    node instanceof Return and kind = "return"
    or
    // 检查节点是否是 yield 语句，并且类型是 "yield"
    node instanceof Yield and kind = "yield"
    or
    // 检查节点是否是 yield from 语句，并且类型是 "yield from"
    node instanceof YieldFrom and kind = "yield from"
  )
// 选择匹配的节点，并生成相应的警告信息
select node, "'" + kind + "' is used outside a function."
