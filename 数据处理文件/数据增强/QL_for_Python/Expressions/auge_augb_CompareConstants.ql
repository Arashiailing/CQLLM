/**
 * @name Comparison of constants
 * @description 检测代码中比较两个常量值的表达式，这种表达式总是产生固定结果，
 *              相比直接使用布尔值降低了代码可读性。
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

// 查找常量比较表达式
from Compare constComparison, Expr lhsOperand, Expr rhsOperand
where
  // 识别比较操作的左右操作数
  constComparison.compares(lhsOperand, _, rhsOperand)
  and
  // 验证两个操作数都是常量
  lhsOperand.isConstant()
  and
  rhsOperand.isConstant()
  and
  // 排除在断言语句中使用的比较（断言可能需要显式表达式）
  not exists(Assert assertStatement | assertStatement.getTest() = constComparison)
select constComparison, "常量比较表达式应替换为 'True' 或 'False'"