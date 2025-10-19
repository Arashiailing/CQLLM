/**
 * @name Use of exit() or quit()
 * @description Identifies calls to exit() or quit() functions which are part of 
 *              the site module and may not be available when Python runs with 
 *              the -S flag that disables site module loading.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析模块，提供Python代码结构分析能力

from CallNode exitOrQuitCall, string exitOrQuitName  // 定义变量：调用节点和退出函数名
where 
  // 检查调用是否指向site模块中的Quitter对象
  exitOrQuitCall.getFunction().pointsTo(Value::siteQuitter(exitOrQuitName))
select 
  exitOrQuitCall,  // 选择符合条件的调用节点
  "Function '" + exitOrQuitName + 
  "' is a site.Quitter object that may not exist when the 'site' module is disabled or modified."