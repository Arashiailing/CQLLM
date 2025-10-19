/**
 * @name Potential missing 'self' reference in comparison
 * @description Detects comparisons between identical values, which may indicate a missing 'self' reference in class methods. Such comparisons often result in logical errors where the condition is always true or always false.
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

import python  // Python代码分析模块，提供Python代码的静态分析能力
import Expressions.RedundantComparison  // 冗余比较表达式分析模块，用于检测可能存在问题的比较操作

from RedundantComparison potentialMissingSelfComparison  // 从冗余比较表达式中选择可能缺少'self'引用的比较操作
where potentialMissingSelfComparison.maybeMissingSelf()  // 条件：比较操作可能缺少'self'引用
select potentialMissingSelfComparison, "Comparison of identical values; may be missing 'self'."  // 选择符合条件的比较操作，并生成警告信息