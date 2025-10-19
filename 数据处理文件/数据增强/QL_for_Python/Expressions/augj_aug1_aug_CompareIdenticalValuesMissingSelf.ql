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

import python  // 提供Python源代码的静态分析基础功能，包括语法树、类型系统等核心分析能力
import Expressions.RedundantComparison  // 专门用于检测冗余比较表达式的分析模块，识别逻辑上可能存在问题的比较操作

from RedundantComparison suspiciousSelfComparison  // 从所有冗余比较表达式中筛选出可疑的比较操作实例
where suspiciousSelfComparison.maybeMissingSelf()  // 筛选条件：识别可能缺少'self'引用的比较操作，这类操作通常在类方法中出现，导致比较相同的值
select suspiciousSelfComparison, "Comparison of identical values; may be missing 'self'."  // 输出结果：显示可疑的比较操作及其位置，并提供可能缺少'self'引用的提示信息