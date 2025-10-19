/**
 * @name Use of exit() or quit()
 * @description Detects calls to exit() or quit() functions which are provided by
 *              the site module. These functions may not be available when Python
 *              runs with the -S flag that prevents automatic site module loading.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  // 导入Python分析模块，提供Python代码结构分析能力

from CallNode problematicCall, string functionName  // 定义变量：存在问题的调用节点和函数名
where 
  // 确认调用指向site模块中的Quitter对象
  problematicCall.getFunction().pointsTo(Value::siteQuitter(functionName))
select 
  problematicCall,  // 选择符合条件的调用节点
  "Function '" + functionName + 
  "' is a site.Quitter object that may not exist when the 'site' module is disabled or modified."