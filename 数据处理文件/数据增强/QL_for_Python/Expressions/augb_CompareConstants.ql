/**
 * @name Comparison of constants
 * @description 比较常量表达式总是产生恒定结果，但比直接使用布尔值更难阅读。
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
from Compare cmpExpr, Expr leftOperand, Expr rightOperand
where
  // 识别比较操作的左右操作数
  cmpExpr.compares(leftOperand, _, rightOperand) and
  // 验证两个操作数都是常量
  leftOperand.isConstant() and
  rightOperand.isConstant() and
  // 排除在断言语句中使用的比较（断言可能需要显式表达式）
  not exists(Assert assertionStmt | assertionStmt.getTest() = cmpExpr)
select cmpExpr, "常量比较表达式应替换为 'True' 或 'False'"