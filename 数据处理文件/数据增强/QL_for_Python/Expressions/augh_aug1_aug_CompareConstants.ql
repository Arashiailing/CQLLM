/**
 * @name Comparison of constants
 * @description 检测代码中两个常量表达式之间的比较。这类比较的结果在编译时就已经确定，
 *              因此是不必要的。用直接常量（True 或 False）替换这些比较可以提高代码的
 *              清晰度、可读性和可维护性。此查询有助于识别可能冗余的比较，以提升代码质量。
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

// 查找两个常量表达式之间的比较操作，排除在断言语句中使用的比较
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // 验证比较操作的操作数
  constantComparison.compares(leftOperand, _, rightOperand) and
  // 验证操作数是否为常量
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // 排除在断言语句中使用的比较
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."