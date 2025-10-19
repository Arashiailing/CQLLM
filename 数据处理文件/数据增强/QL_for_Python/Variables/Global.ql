/**
 * @name Use of the 'global' statement.
 * @description Use of the 'global' statement may indicate poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// 从全局变量中选择所有实例
from Global g
// 过滤条件：全局变量的作用域不是模块级别
where not g.getScope() instanceof Module
// 查询结果：选择符合条件的全局变量，并附带警告信息
select g, "Updating global variables except at module initialization is discouraged."
