/**
 * @name Use of 'global' at module level
 * @description Use of the 'global' statement at module level
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// 导入Python模块，用于处理Python代码的解析和分析
import python

// 从全局变量中选择那些在模块级别声明的变量
from Global g
where g.getScope() instanceof Module // 过滤条件：仅选择作用域为模块级别的全局变量
select g, "Declaring '" + g.getAName() + "' as global at module-level is redundant." // 选择语句：返回全局变量及其冗余声明的警告信息
