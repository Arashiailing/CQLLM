/**
 * @name Comparison of constants
 * @description 检测代码中两个常量值之间的比较操作，这类比较总是产生固定的布尔结果，
 *              直接使用布尔字面值可提高代码可读性和维护性。
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

// 查找涉及两个常量操作数的比较表达式
from Compare constComparison, Expr leftConst, Expr rightConst
where
  // 确保比较操作涉及左右两个操作数
  constComparison.compares(leftConst, _, rightConst) and
  // 验证两个操作数均为常量表达式
  leftConst.isConstant() and
  rightConst.isConstant() and
  // 排除在断言语句中出现的比较（断言可能需要显式表达式用于文档目的）
  not exists(Assert assertContext | assertContext.getTest() = constComparison)
select constComparison, "常量比较表达式应替换为 'True' 或 'False'"