/**
 * @name Comparison of constants
 * @description 检测代码中比较两个常量值的表达式，这种比较总是返回固定结果，
 *              相比直接使用布尔字面量(True/False)降低了代码可读性。
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

// 查找所有常量比较表达式，排除特定合法使用场景
from Compare constCompareExpr, Expr leftOperand, Expr rightOperand
where
  // 识别比较操作的两个操作数
  constCompareExpr.compares(leftOperand, _, rightOperand) and
  // 验证两个操作数都是常量值
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // 排除断言语句中的常量比较，因为断言可能需要显式表达式
  not exists(Assert assertStmt | assertStmt.getTest() = constCompareExpr)
select constCompareExpr, "常量比较表达式应替换为 'True' 或 'False'"