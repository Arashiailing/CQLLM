/**
 * @name Comparison of identical values
 * @description Comparison of identical values, the intent of which is unclear.
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

import python  // 导入Python库，用于分析Python代码
import Expressions.RedundantComparison  // 导入冗余比较表达式的库

// 从RedundantComparison类中获取比较对象
from RedundantComparison identicalComparison
// 应用过滤条件以排除误报情况：
// 1. 排除常量比较，因为它们可能是有意为之
// 2. 排除可能缺少self的比较，以减少误报
where 
  not identicalComparison.isConstant() and 
  not identicalComparison.maybeMissingSelf()
// 选择符合条件的比较对象，并生成警告信息
select identicalComparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."