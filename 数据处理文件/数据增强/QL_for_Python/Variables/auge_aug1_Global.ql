/**
 * @name Use of the 'global' statement.
 * @description Detects usage of 'global' statements outside module scope, which may indicate poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// 查找所有在非模块作用域中使用的 'global' 语句
// 这有助于识别变量作用域和模块化方面的潜在问题
from Global globalDeclaration
// 排除在模块级别定义的全局语句（这是可接受的）
where not globalDeclaration.getScope() instanceof Module
// 报告发现的问题并附带适当的警告信息
select globalDeclaration, "Updating global variables except at module initialization is discouraged."