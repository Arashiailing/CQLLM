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

// 查询目标：检测在全局作用域中使用的特定控制流语句
from AstNode invalidStmt, string stmtType
where 
  // 识别三类目标语句类型
  (
    invalidStmt instanceof Return and stmtType = "return"
    or
    invalidStmt instanceof Yield and stmtType = "yield"
    or
    invalidStmt instanceof YieldFrom and stmtType = "yield from"
  )
  and
  // 验证语句不在任何函数作用域内
  not exists(Function containingFunction | 
             invalidStmt.getScope() = containingFunction.getScope()
            )
// 输出违规语句及其错误描述
select invalidStmt, "'" + stmtType + "' is used outside a function."