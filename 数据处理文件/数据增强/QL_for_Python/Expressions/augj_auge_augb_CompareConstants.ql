/**
 * @name Comparison of constants
 * @description 识别代码中比较两个常量值的表达式。这类表达式总是产生固定结果，
 *              直接使用布尔常量会提高代码可读性和维护性。
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

// 检测常量比较表达式
from Compare constantComparisonExpr, Expr leftOperand, Expr rightOperand
where
  // 确保这是一个比较操作，且左右操作数都是常量
  constantComparisonExpr.compares(leftOperand, _, rightOperand)
  and
  leftOperand.isConstant()
  and
  rightOperand.isConstant()
  and
  // 排除断言语句中的常量比较
  not exists(Assert assertStmt | 
    assertStmt.getTest() = constantComparisonExpr
  )
select constantComparisonExpr, "常量比较表达式应替换为 'True' 或 'False'"