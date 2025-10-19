/**
 * @name Detection of 'return' or 'yield' statements outside function scope
 * @description Identifies usage of 'return', 'yield', or 'yield from' statements 
 *              outside of function definitions, which leads to runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查询目标：检测在全局作用域中错误使用的关键字语句
from AstNode invalidStmt, string statementType
where 
  // 第一部分：识别目标语句类型并分类
  (
    invalidStmt instanceof Return and statementType = "return"
    or
    invalidStmt instanceof Yield and statementType = "yield"
    or
    invalidStmt instanceof YieldFrom and statementType = "yield from"
  )
  and
  // 第二部分：确保语句不在任何函数的作用域内
  not exists(Function parentFunction | invalidStmt.getScope() = parentFunction.getScope())
// 输出结果：违规语句及其错误描述
select invalidStmt, "'" + statementType + "' is used outside a function."