/**
 * @name Comparison of constants
 * @description 比较两个常量表达式的结果总是恒定的，但直接使用常量（如True或False）更易读。
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
from Compare constantComparison, Expr leftOperand, Expr rightOperand
where
  // 确保是比较操作且左右操作数都是常量
  constantComparison.compares(leftOperand, _, rightOperand) and
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // 排除在断言语句中使用的比较（断言中可能需要显式比较）
  not exists(Assert assertion | assertion.getTest() = constantComparison)
select constantComparison, "Comparison of constants; use 'True' or 'False' instead."