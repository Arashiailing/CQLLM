/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies comparison operations between identical values that might suggest a missing 'self' reference in class methods. These comparisons typically lead to logical flaws causing the condition to evaluate to either always true or always false.
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

import python  // 模块用于Python代码的静态分析，提供访问Python语法树的能力
import Expressions.RedundantComparison  // 模块专注于识别和检测冗余比较表达式，帮助发现潜在编码问题

from RedundantComparison redundantExprWithMissingSelf  // 查询源：从冗余比较表达式集合中选取可能缺少'self'引用的表达式
where redundantExprWithMissingSelf.maybeMissingSelf()  // 筛选条件：确保表达式确实可能存在缺少'self'引用的情况
select redundantExprWithMissingSelf, "Comparison of identical values; may be missing 'self'."  // 输出结果：返回有问题的表达式及相应的警告信息