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
from RedundantComparison comparison
// 过滤条件：排除常量比较和可能缺少self的比较
where not comparison.isConstant() and not comparison.maybeMissingSelf()
// 选择符合条件的比较对象，并生成警告信息
select comparison, "Comparison of identical values; use cmath.isnan() if testing for not-a-number."
