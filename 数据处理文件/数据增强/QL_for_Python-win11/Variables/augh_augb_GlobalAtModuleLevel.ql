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

// 导入Python分析库，用于解析Python代码结构
import python

// 识别在模块作用域中使用global关键字声明的变量
// 此类声明是不必要的，因为模块级变量天然具有全局作用域
from Global moduleLevelGlobal
where 
    // 验证全局声明是否位于模块作用域内
    // 在模块作用域中使用global是多余的，因为该作用域内的变量默认为全局变量
    moduleLevelGlobal.getScope() instanceof Module
select 
    moduleLevelGlobal, 
    // 生成警告信息，提示冗余的全局声明
    "Declaring '" + moduleLevelGlobal.getAName() + "' as global at module-level is redundant."