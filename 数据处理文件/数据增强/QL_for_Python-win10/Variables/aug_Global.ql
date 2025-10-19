/**
 * @name Use of the 'global' statement.
 * @description Use of the 'global' statement may indicate poor modularity.
 *              This query identifies global variables used outside of module scope,
 *              which can make code harder to maintain.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// 查找所有全局变量声明
from Global globalVar
// 过滤条件：确保全局变量的作用域不是模块级别
where not globalVar.getScope() instanceof Module
// 返回结果：全局变量实例及其相关的警告信息
select globalVar, "Updating global variables except at module initialization is discouraged."