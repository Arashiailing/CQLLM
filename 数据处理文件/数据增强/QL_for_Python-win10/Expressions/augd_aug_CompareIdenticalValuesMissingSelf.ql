/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies comparisons where identical values are compared, 
 *              which often indicates a missing 'self' reference in class methods.
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
import Expressions.RedundantComparison  // 专门用于识别冗余或可能有问题的比较表达式

from RedundantComparison redundantExpr  // 从冗余比较表达式中筛选出潜在的问题代码
where 
  // 检查比较表达式是否可能缺少'self'引用
  // 这种情况通常发生在类方法中，开发者忘记使用self引用实例变量
  redundantExpr.maybeMissingSelf()
select 
  redundantExpr, 
  "Detected comparison between identical values; this may indicate a missing 'self' reference in a class method."