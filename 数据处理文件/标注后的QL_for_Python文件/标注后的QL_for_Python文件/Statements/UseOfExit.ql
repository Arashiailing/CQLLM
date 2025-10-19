/**
 * @name Use of exit() or quit()
 * @description exit() or quit() may fail if the interpreter is run with the -S option.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/use-of-exit-or-quit
 */

import python  # 导入Python库，用于处理Python代码的查询

from CallNode call, string name  # 从CallNode中获取调用节点和字符串类型的名称
where call.getFunction().pointsTo(Value::siteQuitter(name))  # 条件：调用的函数指向siteQuitter对象
select call,  # 选择符合条件的调用节点
  "The '" + name +
    "' site.Quitter object may not exist if the 'site' module is not loaded or is modified."  # 警告信息：如果'site'模块未加载或被修改，则'site.Quitter'对象可能不存在。
