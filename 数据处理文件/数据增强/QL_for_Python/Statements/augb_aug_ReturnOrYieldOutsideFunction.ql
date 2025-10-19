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

// 查询目标：定位在全局作用域中使用的关键语句
from AstNode problematicStmt, string stmtCategory
where 
  // 识别特定类型的语句
  (
    problematicStmt instanceof Return and stmtCategory = "return"
    or
    problematicStmt instanceof Yield and stmtCategory = "yield"
    or
    problematicStmt instanceof YieldFrom and stmtCategory = "yield from"
  ) and
  // 验证这些语句不在函数作用域内
  not exists(Function enclosingFunc | problematicStmt.getScope() = enclosingFunc.getScope())
// 输出违规语句及其错误描述
select problematicStmt, "'" + stmtCategory + "' is used outside a function."