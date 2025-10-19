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

// 导入Python语言模块，提供Python代码分析的基础功能
import python

// 查找在模块级别使用'global'关键字声明的变量
// 在Python中，模块级别定义的变量默认就是全局变量，
// 因此使用'global'关键字声明是多余的，不会改变变量的作用域
from Global redundantGlobalDeclaration
where 
    // 确认全局变量的声明作用域是模块级别
    // 在模块级别，所有变量默认都是全局的，不需要显式声明
    redundantGlobalDeclaration.getScope() instanceof Module
select 
    redundantGlobalDeclaration, 
    // 生成警告消息，指出冗余的全局声明
    "Declaring '" + redundantGlobalDeclaration.getAName() + "' as global at module-level is redundant."