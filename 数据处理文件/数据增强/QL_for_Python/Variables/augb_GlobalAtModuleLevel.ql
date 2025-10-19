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

// 引入Python分析库，提供对Python代码结构的访问能力
import python

// 查找所有在模块级别声明的全局变量声明
// 这些声明是多余的，因为在模块级别定义的变量默认就是全局的
from Global globalDecl
where 
    // 检查全局声明的作用域是否为模块级别
    // 在模块级别使用global关键字是多余的，因为模块级别的变量默认就是全局的
    globalDecl.getScope() instanceof Module
select 
    globalDecl, 
    // 构建警告消息，指出冗余的全局声明
    "Declaring '" + globalDecl.getAName() + "' as global at module-level is redundant."