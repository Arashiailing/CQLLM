/**
 * @name Potential missing 'self' reference in comparison
 * @description Identifies comparisons involving identical values, potentially indicating an omitted 'self' reference.
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

import python  // 提供Python代码静态分析的基础功能
import Expressions.RedundantComparison  // 用于检测比较表达式中的冗余性问题

// 查找可能缺少'self'引用的冗余比较表达式
from RedundantComparison redundantExpr
where redundantExpr.maybeMissingSelf()
select redundantExpr, "Comparison of identical values; may be missing 'self'."