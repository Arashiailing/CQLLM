/**
 * @name Comparison of constants
 * @description 比较常量总是恒定的，但比简单的常量更难读。
 * @kind problem
 * @tags maintainability
 *       useless-code
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/comparison-of-constants
 */

import python

// 查找常量比较表达式：两个常量之间的比较操作
from Compare cmpExpr, Expr lhsOperand, Expr rhsOperand
where
  // 确认是比较操作并获取左右操作数
  cmpExpr.compares(lhsOperand, _, rhsOperand) and
  // 验证两个操作数都是常量值
  lhsOperand.isConstant() and
  rhsOperand.isConstant() and
  // 排除在断言上下文中使用的常量比较（断言中可能有特殊用途）
  not exists(Assert assertStmt | assertStmt.getTest() = cmpExpr)
select cmpExpr, "Comparison of constants; use 'True' or 'False' instead."