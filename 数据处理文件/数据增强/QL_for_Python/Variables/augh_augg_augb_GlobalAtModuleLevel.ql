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

// 引入Python语言分析模块，提供语法树节点访问和代码结构分析功能
import python

// 查找在模块作用域内声明的全局变量
// 在Python中，模块级别的变量天然具有全局作用域，因此显式使用global声明是多余的
from Global moduleLevelGlobal
where 
    // 检查global声明的作用域是否为模块级别
    // 模块作用域内的变量自动成为全局变量，不需要显式声明
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // 生成警告信息，指出该global声明是不必要的
    "Declaring '" + moduleLevelGlobal.getAName() + "' as global at module-level is redundant."