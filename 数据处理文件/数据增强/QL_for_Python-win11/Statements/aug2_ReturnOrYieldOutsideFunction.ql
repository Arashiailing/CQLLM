/**
 * @name Incorrect usage of 'return' or 'yield' outside function scope
 * @description Placing 'return', 'yield', or 'yield from' statements outside a function definition
 *              will result in a 'SyntaxError' when the code is executed.
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
from AstNode stmtNode, string stmtType
where
  (
    // 检查节点是否是 return 语句，并且类型是 "return"
    stmtNode instanceof Return and stmtType = "return"
    or
    // 检查节点是否是 yield 语句，并且类型是 "yield"
    stmtNode instanceof Yield and stmtType = "yield"
    or
    // 检查节点是否是 yield from 语句，并且类型是 "yield from"
    stmtNode instanceof YieldFrom and stmtType = "yield from"
  ) and
  // 检查节点是否不在函数的作用域内
  not stmtNode.getScope() instanceof Function
// 选择匹配的节点，并生成相应的警告信息
select stmtNode, "Statement '" + stmtType + "' is used outside a function definition."