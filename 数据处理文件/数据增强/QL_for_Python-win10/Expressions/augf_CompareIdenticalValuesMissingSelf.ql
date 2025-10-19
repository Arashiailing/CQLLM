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

// 导入Python分析库
import python

// 导入用于检测冗余比较表达式的模块
import Expressions.RedundantComparison

// 查找冗余比较表达式
from RedundantComparison redundantComp

// 筛选出可能缺少'self'的比较
where redundantComp.maybeMissingSelf()

// 输出结果和警告信息
select redundantComp, "Comparison of identical values; may be missing 'self'."