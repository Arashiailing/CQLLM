/**
 * @name Detection of 'return' or 'yield' statements used outside function scope
 * @description Identifies code locations where 'return', 'yield', or 'yield from' statements are incorrectly placed outside function definitions, which would cause a 'SyntaxError' at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 识别所有可能是违规的语句节点及其类型
from AstNode problematicStmt, string stmtType
where 
  (
    // 检查是否为 return 语句
    problematicStmt instanceof Return and stmtType = "return"
    or
    // 检查是否为 yield 语句
    problematicStmt instanceof Yield and stmtType = "yield"
    or
    // 检查是否为 yield from 语句
    problematicStmt instanceof YieldFrom and stmtType = "yield from"
  ) and
  // 验证该语句确实位于任何函数作用域之外
  not exists(Function enclosingFunc | problematicStmt.getScope() = enclosingFunc.getScope())
// 输出结果：违规语句节点及对应的错误描述
select problematicStmt, "'" + stmtType + "' is used outside a function."