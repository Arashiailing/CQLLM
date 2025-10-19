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

// 导入Python代码分析库，提供对Python语法结构的解析和访问能力
import python

// 识别在模块级别使用global关键字声明的变量
// 在Python中，模块作用域内定义的变量默认具有全局可见性，因此显式使用global声明是多余的
from Global redundantGlobal
where 
    // 验证全局声明是否位于模块作用域内
    // 模块级别的变量天生就是全局变量，无需额外声明
    redundantGlobal.getScope() instanceof Module
select 
    redundantGlobal, 
    // 构建警告消息，提示开发者此处global声明是不必要的
    "Declaring '" + redundantGlobal.getAName() + "' as global at module-level is redundant."