/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() which may not be available when 
 *              the Python interpreter runs with the -S flag (disables 'site' module)
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python模块，用于分析Python代码结构

from CallNode exitCall, string exitFunctionName  // 获取退出函数调用节点和函数名
where 
  // 验证调用是否指向site模块的Quitter对象
  exitCall.getFunction().pointsTo(Value::siteQuitter(exitFunctionName))
select 
  exitCall,  // 选择符合条件的退出函数调用
  "The '" + exitFunctionName + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."