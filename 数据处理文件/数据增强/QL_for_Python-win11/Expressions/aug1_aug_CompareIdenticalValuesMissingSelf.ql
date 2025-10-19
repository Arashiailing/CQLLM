/**
 * @name Potential missing 'self' reference in comparison
 * @description Detects comparisons between identical values, which may indicate a missing 'self' reference.
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

import python  // 导入Python代码分析模块，提供对Python源代码的静态分析能力
import Expressions.RedundantComparison  // 导入冗余比较表达式分析模块，用于识别可能存在逻辑错误的比较操作

from RedundantComparison potentiallyMissingSelfComparison  // 从冗余比较表达式集合中筛选出可能缺少'self'引用的比较操作
where potentiallyMissingSelfComparison.maybeMissingSelf()  // 筛选条件：比较操作可能缺少'self'引用，导致比较相同值
select potentiallyMissingSelfComparison, "Comparison of identical values; may be missing 'self'."  // 输出结果：显示可疑的比较操作，并提示可能缺少'self'引用