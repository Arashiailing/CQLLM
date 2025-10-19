/**
 * @name Misplaced 'return' or 'yield' statements outside function boundaries
 * @description Identifies 'return', 'yield', or 'yield from' statements located
 *              outside function definitions, leading to 'SyntaxError' in Python.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision medium
 * @id py/return-or-yield-outside-function
 */

import python

// 定位函数外部使用的违规语句
from AstNode misplacedStmt, string stmtKind
where
  // 判断语句类型
  (
    misplacedStmt instanceof Return and stmtKind = "return"
    or
    misplacedStmt instanceof Yield and stmtKind = "yield"
    or
    misplacedStmt instanceof YieldFrom and stmtKind = "yield from"
  )
  and
  // 验证语句不在函数作用域内
  not misplacedStmt.getScope() instanceof Function
// 输出警告信息
select misplacedStmt, "Statement '" + stmtKind + "' is used outside a function definition."