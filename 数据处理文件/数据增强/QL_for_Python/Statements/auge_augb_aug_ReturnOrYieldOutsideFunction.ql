/**
 * @name Return/Yield Statements Outside Function Scope
 * @description Detects 'return', 'yield', or 'yield from' statements that appear 
 *              outside function definitions, causing runtime 'SyntaxError'.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 查询目标：识别在全局作用域中使用的特定语句
from AstNode invalidStmt, string stmtType
where 
  // 确定语句类型
  (
    invalidStmt instanceof Return and stmtType = "return"
    or
    invalidStmt instanceof Yield and stmtType = "yield"
    or
    invalidStmt instanceof YieldFrom and stmtType = "yield from"
  ) and
  // 验证语句不在任何函数的作用域内
  not exists(Function parentFunction | invalidStmt.getScope() = parentFunction.getScope())
// 输出结果：违规语句及其错误描述
select invalidStmt, "'" + stmtType + "' is used outside a function."