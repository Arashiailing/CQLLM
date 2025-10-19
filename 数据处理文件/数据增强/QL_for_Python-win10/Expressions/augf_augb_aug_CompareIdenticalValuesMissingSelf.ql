/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies comparisons where identical values are compared, which could be a sign of a missing 'self' reference in class methods. These comparisons typically lead to logical errors where the condition evaluates to either always true or always false.
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

import python  // 导入Python代码分析模块，提供静态分析Python代码的能力
import Expressions.RedundantComparison  // 导入冗余比较表达式分析模块，用于识别潜在有问题的比较操作

from RedundantComparison suspectComparison  // 从冗余比较表达式中筛选出可疑的比较操作
where suspectComparison.maybeMissingSelf()  // 筛选条件：比较操作可能缺少'self'引用
select suspectComparison, "Comparison of identical values; may be missing 'self'."  // 输出可疑比较操作及相应的警告信息