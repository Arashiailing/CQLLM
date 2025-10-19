/**
 * @name Maybe missing 'self' in comparison
 * @description Comparison of identical values, the intent of which is unclear.
 * @kind problem
 * @tags reliability
 *       maintainability
 *       external/cwe/cwe-570
 *       external/cwe/cwe-571
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/comparison-missing-self
 */

import python  // 导入Python库，用于分析Python代码
import Expressions.RedundantComparison  // 导入冗余比较表达式模块

from RedundantComparison comparison  // 从冗余比较表达式中选择比较操作
where comparison.maybeMissingSelf()  // 条件：比较操作可能缺少'self'
select comparison, "Comparison of identical values; may be missing 'self'."  // 选择符合条件的比较操作，并生成警告信息
