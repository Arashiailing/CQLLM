/**
 * @name Redundant module-level global declaration
 * @description Detects unnecessary 'global' statements at module scope
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// 导入Python语言分析模块，用于访问语法树节点和分析代码结构
import python

// 识别在模块顶层作用域中声明的全局变量
// Python中，模块级变量默认具有全局作用域，显式声明global是多余的
from Global redundantGlobalDecl
where 
    // 验证global声明是否位于模块作用域内
    // 模块作用域中的变量天然是全局的，无需显式声明
    redundantGlobalDecl.getScope() instanceof Module
select 
    redundantGlobalDecl, 
    // 构造警告消息，说明该global声明是不必要的
    "Declaring '" + redundantGlobalDecl.getAName() + "' as global at module-level is redundant."