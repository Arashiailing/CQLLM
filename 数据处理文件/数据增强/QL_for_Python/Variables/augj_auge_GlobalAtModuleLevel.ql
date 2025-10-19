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

// 引入Python语言模块以支持代码分析和抽象语法树遍历
import python

// 定位在模块作用域内出现的全局变量声明
from Global moduleLevelGlobalDecl
where 
  // 将分析范围限定于仅出现在模块上下文中的全局声明
  exists(Module mod | moduleLevelGlobalDecl.getScope() = mod)
select 
  moduleLevelGlobalDecl, 
  // 构建警告消息以突出显示冗余的全局变量使用
  "Declaring '" + moduleLevelGlobalDecl.getAName() + "' as global at module-level is redundant."