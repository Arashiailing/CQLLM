/**
 * @name Comparison of identical values
 * @description Detects comparisons where both sides are identical values, which typically indicates unclear intent.
 * @kind problem
 * @tags reliability
 *       correctness
 *       readability
 *       convention
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-of-identical-expressions
 */

import python  // 导入Python分析库，用于解析Python代码结构
import Expressions.RedundantComparison  // 导入用于检测冗余比较表达式的模块

// 从RedundantComparison类中获取冗余比较表达式实例
from RedundantComparison redundantExpr
// 应用过滤条件以排除特定情况
where 
  // 排除常量之间的比较，因为这些可能是有意为之
  not redundantExpr.isConstant() 
  and 
  // 排除可能缺少self引用的比较，这些可能是特殊用例
  not redundantExpr.maybeMissingSelf()
// 选择符合条件的冗余比较表达式，并提供修复建议
select redundantExpr, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."