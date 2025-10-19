/**
 * @name Comparison of constants
 * @description 检测代码中两个常量之间的比较操作，这种比较总是产生恒定结果，
 *              但比直接使用True或False更难以理解。
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

// 定义变量：比较表达式及其左右操作数
from Compare comparisonExpr, Expr leftOperand, Expr rightOperand
where
  // 确保是比较操作并获取左右操作数
  comparisonExpr.compares(leftOperand, _, rightOperand)
  and
  // 验证左操作数是常量值
  leftOperand.isConstant()
  and
  // 验证右操作数是常量值
  rightOperand.isConstant()
  and
  // 排除在断言语句中使用的常量比较（断言中可能有特殊用途）
  not exists(Assert assertionStmt | assertionStmt.getTest() = comparisonExpr)
select comparisonExpr, "Comparison of constants; use 'True' or 'False' instead."