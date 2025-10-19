/**
 * @name 'apply' function used
 * @description The builtin function 'apply' is obsolete and should not be used.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python  // 导入Python库，用于分析Python代码
private import semmle.python.types.Builtins  // 私有导入Python内置类型库

// 从CallNode和ControlFlowNode中选择调用节点和控制流节点
from CallNode call, ControlFlowNode func
// 条件：主版本号为2且调用的函数是目标函数，并且目标函数指向名为"apply"的值
where major_version() = 2 and call.getFunction() = func and func.pointsTo(Value::named("apply"))
// 选择符合条件的调用节点，并生成警告信息
select call, "Call to the obsolete builtin function 'apply'."
