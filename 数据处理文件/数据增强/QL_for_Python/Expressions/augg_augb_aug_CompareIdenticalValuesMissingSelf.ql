/**
 * @name Potential missing 'self' reference in comparison
 * @description 识别可能缺少'self'引用的类方法中的相同值比较。这些比较通常导致逻辑错误，使条件始终为真或假。
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

import python  // 提供Python代码的静态分析功能
import Expressions.RedundantComparison  // 启用对潜在问题比较操作的检测

from RedundantComparison redundantCompExpr  // 选择可能缺少'self'引用的比较表达式
where redundantCompExpr.maybeMissingSelf()  // 筛选出可能缺少'self'引用的比较
select redundantCompExpr, "Comparison of identical values; may be missing 'self'."  // 输出有问题的比较及警告信息