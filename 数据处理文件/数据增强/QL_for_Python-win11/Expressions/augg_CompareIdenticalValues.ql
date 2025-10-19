/**
 * @name Comparison of identical values
 * @description Identifies code locations where a comparison is made between identical values,
 *              which typically indicates unclear programming intent or potential logic errors.
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

import python  // 导入Python库，用于分析Python代码
import Expressions.RedundantComparison  // 导入冗余比较表达式检测模块

// 查询冗余比较表达式
from RedundantComparison identicalExprComparison
// 应用过滤条件：排除常量比较和可能缺少self的比较
where 
  not identicalExprComparison.isConstant() and 
  not identicalExprComparison.maybeMissingSelf()
// 选择符合条件的比较表达式，并提供警告信息
select identicalExprComparison, 
       "Comparison of identical values; use cmath.isnan() if testing for not-a-number."