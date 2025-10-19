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

// 导入Python分析库，提供对Python代码结构的访问能力
import python

// 查找所有在模块作用域中声明的冗余全局变量
// 在模块级别使用global关键字是多余的，因为模块级别的变量默认具有全局作用域
from Global redundantGlobal
where 
    // 确保全局声明位于模块级别作用域中
    // 模块级别的变量默认就是全局的，因此不需要显式声明为global
    redundantGlobal.getScope() instanceof Module
select 
    redundantGlobal, 
    // 生成警告消息，指明冗余的全局声明
    "Declaring '" + redundantGlobal.getAName() + "' as global at module-level is redundant."