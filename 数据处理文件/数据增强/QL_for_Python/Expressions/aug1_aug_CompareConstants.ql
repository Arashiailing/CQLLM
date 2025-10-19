/**
 * @name Comparison of constants
 * @description 检测代码中比较两个常量表达式的情况。这种比较的结果在编译时就已经确定，
 *              直接使用常量（如 True 或 False）会使代码更简洁、易读和维护。
 *              此查询有助于识别可能的不必要比较，提高代码质量。
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

// 查找比较两个常量表达式的比较操作，且该比较操作不在断言语句中使用
from Compare constExprComparison, Expr leftConstOperand, Expr rightConstOperand
where
  // 确保是比较操作且左右操作数都是常量
  constExprComparison.compares(leftConstOperand, _, rightConstOperand) and
  leftConstOperand.isConstant() and
  rightConstOperand.isConstant() and
  // 排除在断言语句中使用的比较（断言中可能需要显式比较）
  not exists(Assert assertion | assertion.getTest() = constExprComparison)
select constExprComparison, "Comparison of constants; use 'True' or 'False' instead."