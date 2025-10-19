/**
 * @name Comparison of constants
 * @description 检测代码中常量之间的比较操作。这种比较总是产生固定的布尔结果，
 *              直接使用布尔值更易读且减少代码复杂性。
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

// 识别常量比较表达式
from Compare constantComparison
where
  // 获取比较操作的两个操作数并验证它们都是常量
  exists(Expr leftExpr, Expr rightExpr |
    constantComparison.compares(leftExpr, _, rightExpr) and
    leftExpr.isConstant() and
    rightExpr.isConstant()
  ) and
  // 排除断言语句中的常量比较（断言中可能需要显式表达式来增强可读性）
  not exists(Assert assertStmt | assertStmt.getTest() = constantComparison)
select constantComparison, "常量比较表达式应替换为 'True' 或 'False'"