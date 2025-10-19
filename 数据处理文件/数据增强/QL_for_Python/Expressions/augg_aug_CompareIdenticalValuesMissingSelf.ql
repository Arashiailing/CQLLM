/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies code locations where a comparison is made between identical values,
 *              which often indicates a programmer's intention to compare an instance attribute
 *              with itself but omitted the 'self' reference.
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

import python  // 提供Python代码的静态分析基础功能
import Expressions.RedundantComparison  // 用于识别冗余或可疑比较操作的分析模块

from RedundantComparison redundantExpr  // 获取所有冗余比较表达式
where redundantExpr.maybeMissingSelf()  // 筛选出可能缺少'self'引用的比较操作
select redundantExpr, "Comparison of identical values; may be missing 'self'."  // 报告问题并提供建议性描述