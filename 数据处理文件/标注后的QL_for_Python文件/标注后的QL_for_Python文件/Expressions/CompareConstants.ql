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

// 定义一个查询，用于查找比较常量的表达式
from Compare comparison, Expr left, Expr right
where
  // 检查是否存在比较操作，并且左右两边都是常量
  comparison.compares(left, _, right) and
  left.isConstant() and
  right.isConstant() and
  // 确保没有断言语句使用这个比较结果
  not exists(Assert a | a.getTest() = comparison)
select comparison, "Comparison of constants; use 'True' or 'False' instead."
