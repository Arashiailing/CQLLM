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

// 查询范围：识别所有全局变量声明语句
from Global globalStmt

// 过滤条件：排除模块级别作用域的全局变量
// 这确保我们只捕获在函数或类内部使用 'global' 关键字的情况
where not globalStmt.getScope() instanceof Module

// 结果输出：返回全局变量声明实例及其相关的警告信息
select globalStmt, "Updating global variables except at module initialization is discouraged."