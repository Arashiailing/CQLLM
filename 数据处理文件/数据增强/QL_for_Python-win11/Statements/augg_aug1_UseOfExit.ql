/**
 * @name 调用exit()或quit()函数
 * @description 当Python解释器使用-S选项运行时，调用exit()或quit()可能会失败，因为它们依赖于site模块。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析库，用于处理Python代码的查询分析

from CallNode callNode, string exitFuncName  // 从调用节点中获取函数调用和退出函数名称
where 
  // 获取被调用函数的引用，并验证其是否指向site模块的退出器对象
  callNode.getFunction().pointsTo(Value::siteQuitter(exitFuncName))
select 
  callNode,  // 选择符合条件的函数调用节点
  "调用 '" + exitFuncName + "' 可能存在问题：当'site'模块未加载或被修改时，site.Quitter对象可能不可用。"  // 警告信息