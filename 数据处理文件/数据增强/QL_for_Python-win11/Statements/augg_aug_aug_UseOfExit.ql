/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() which may fail when Python runs 
 *              with the -S flag (disables the 'site' module)
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python模块，用于分析Python代码结构

from CallNode exitOrQuitInvocation, string exitOrQuitFunction  // 获取调用节点和退出函数名称
where 
  // 验证调用是否指向site模块的Quitter对象
  exitOrQuitInvocation.getFunction().pointsTo(Value::siteQuitter(exitOrQuitFunction))
select 
  exitOrQuitInvocation,  // 选择符合条件的方法调用
  "The '" + exitOrQuitFunction + 
  "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."