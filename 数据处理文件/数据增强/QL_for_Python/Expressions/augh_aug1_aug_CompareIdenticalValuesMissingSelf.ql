/**
 * @name Possible absence of 'self' in comparison operations
 * @description Identifies comparisons where identical values are compared, potentially indicating an omitted 'self' reference.
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

import python  // Python源代码静态分析能力提供模块
import Expressions.RedundantComparison  // 用于识别逻辑错误比较操作的表达式分析模块

from RedundantComparison comparisonWithMissingSelf  // 筛选可能缺少'self'引用的比较操作
where comparisonWithMissingSelf.maybeMissingSelf()  // 条件：比较操作可能因缺少'self'引用而导致比较相同值
select comparisonWithMissingSelf, "Identical values compared; possibly missing 'self' reference."  // 输出可疑比较操作及提示信息