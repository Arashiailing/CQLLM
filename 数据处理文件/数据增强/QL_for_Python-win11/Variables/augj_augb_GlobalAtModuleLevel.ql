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

// 导入Python代码分析库，提供对Python程序结构的访问能力
import python

// 查询目标：识别在模块顶层作用域中声明的全局变量
// 此类声明是冗余的，因为模块级别定义的变量默认具有全局作用域
from Global redundantGlobalDecl
where 
    // 检查全局声明是否位于模块作用域内
    // 在模块级别使用global关键字是不必要的，因为此级别的变量天然就是全局的
    redundantGlobalDecl.getScope() instanceof Module
select 
    redundantGlobalDecl, 
    // 构建警告消息，指明冗余的全局声明及其原因
    "Global declaration of '" + redundantGlobalDecl.getAName() + "' at module level is redundant. Module-level variables are global by default."