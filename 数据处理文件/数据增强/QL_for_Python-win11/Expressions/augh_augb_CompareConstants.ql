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

// 识别常量比较表达式并排除特定场景
from Compare constantComparison, Expr leftSide, Expr rightSide
where
  // 确定比较操作的两个操作数
  constantComparison.compares(leftSide, _, rightSide) and
  // 验证两个操作数都是常量值
  leftSide.isConstant() and
  rightSide.isConstant() and
  // 排除断言语句中的常量比较，因为断言可能需要显式表达式
  not exists(Assert assertStatement | assertStatement.getTest() = constantComparison)
select constantComparison, "常量比较表达式应替换为 'True' 或 'False'"