/**
 * @name 调用exit()或quit()函数
 * @description 检测代码中对exit()或quit()函数的调用。这些函数在Python解释器使用-S选项运行时可能会失败，
 *              因为它们依赖于site模块，而-S选项会阻止自动导入site模块。
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析库，提供对Python代码的分析能力

from CallNode exitOrQuitCall, string exitFunctionName  // 从调用节点中获取exit/quit函数调用及其名称
where 
  // 检查函数调用是否指向site模块中的退出器对象（exit或quit）
  exitOrQuitCall.getFunction().pointsTo(Value::siteQuitter(exitFunctionName))
select 
  exitOrQuitCall,  // 选择符合条件的函数调用节点
  "调用 '" + exitFunctionName + "' 可能存在问题：当'site'模块未加载或被修改时，site.Quitter对象可能不可用。"  // 警告信息