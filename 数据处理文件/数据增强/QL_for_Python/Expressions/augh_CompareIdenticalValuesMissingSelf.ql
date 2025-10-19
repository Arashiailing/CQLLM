/**
 * @name Potentially missing 'self' parameter in comparison
 * @description This query identifies comparisons between identical values in Python code,
 *              which often indicate a potential issue where the developer might have
 *              forgotten to include the 'self' parameter in a method call. Such comparisons
 *              are typically redundant and may lead to unexpected behavior.
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

from RedundantComparison suspiciousComparison  // 从冗余比较表达式中选择可疑的比较操作
where suspiciousComparison.maybeMissingSelf()  // 筛选条件：比较操作可能缺少'self'参数
select suspiciousComparison, "Comparison of identical values; may be missing 'self'."  // 输出结果和警告信息