/**
 * @name Improper usage of 'return' or 'yield' statements outside function scope
 * @description This query identifies instances where 'return' or 'yield' statements are incorrectly placed outside of function definitions, which would result in a runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查找所有违规的语句节点及其类型
from AstNode statementNode, string statementKind
where 
  // 检查语句是否位于函数作用域之外
  not exists(Function functionDef | statementNode.getScope() = functionDef.getScope()) and
  (
    // 识别 return 语句
    statementNode instanceof Return and statementKind = "return"
    or
    // 识别 yield 语句
    statementNode instanceof Yield and statementKind = "yield"
    or
    // 识别 yield from 语句
    statementNode instanceof YieldFrom and statementKind = "yield from"
  )
// 输出结果：违规语句节点及对应的错误描述
select statementNode, "'" + statementKind + "' is used outside a function."