/**
 * @name Detection of non-module global variable usage.
 * @description Identifies instances where the 'global' keyword is used outside of module scope,
 *              which can lead to code that is difficult to maintain and understand.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// 该查询用于检测在非模块作用域内使用全局变量声明的情况
// 在函数或类内部使用全局变量可能导致代码行为难以预测和维护
// 理想情况下，全局变量应在模块级别定义和使用
from Global nonModuleGlobal
// 条件检查：确保全局变量声明不在模块作用域内
// 即，全局变量声明位于函数、方法或其他非模块的代码块中
where not nonModuleGlobal.getScope() instanceof Module
// 输出结果：显示非模块作用域内的全局变量声明，并提供相应的警告消息
select nonModuleGlobal, "Modifying global variables outside of module initialization is considered a bad practice."