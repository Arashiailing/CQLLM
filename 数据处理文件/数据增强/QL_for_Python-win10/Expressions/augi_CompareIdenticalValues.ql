/**
 * @name Identical value comparison
 * @description Detects comparisons where both sides are the same value, which may indicate unclear intent.
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

import python  // 导入Python分析库，用于处理Python代码结构
import Expressions.RedundantComparison  // 引入冗余比较表达式分析模块

// 查找冗余比较表达式实例
from RedundantComparison identicalComparison
// 应用过滤条件以减少误报：
// 1. 排除常量比较，因为它们可能是故意的（例如，用于占位符或测试）
// 2. 排除可能缺少self引用的情况，因为它们可能是合法的属性访问
where 
  not identicalComparison.isConstant() and 
  not identicalComparison.maybeMissingSelf()
// 输出结果并生成警告信息，建议使用适当的函数进行NaN检查
select identicalComparison, "Identical values comparison detected; consider using cmath.isnan() for not-a-number checks."