/**
 * @name Constant-to-constant comparison
 * @description Identifies comparisons between two constant values, which always yield a fixed result.
 *              Such comparisons are less readable than directly using 'True' or 'False'.
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

// 查找常量之间的比较表达式
from Compare constComparison, Expr leftConst, Expr rightConst
where
  // 确保是比较操作且左右操作数都是常量
  constComparison.compares(leftConst, _, rightConst)
  and
  // 检查两个操作数是否都是常量
  leftConst.isConstant() and rightConst.isConstant()
  and
  // 排除断言语句中的常量比较，因为它们可能有特殊用途
  not exists(Assert assertStmt | assertStmt.getTest() = constComparison)
select constComparison, "Comparison of constants; use 'True' or 'False' instead."