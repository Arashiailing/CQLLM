/**
 * @name Usage of 'apply' function detected
 * @description This query identifies calls to the builtin 'apply' function, which is considered outdated and should be avoided in modern Python code.
 * @kind problem
 * @tags maintainability
 * @problem.severity warning
 * @sub-severity high
 * @precision very-high
 * @id py/use-of-apply
 */

import python  // 导入Python库，用于分析Python代码
private import semmle.python.types.Builtins  // 私有导入Python内置类型库

// 从CallNode和ControlFlowNode中选择函数调用节点和目标函数节点
from CallNode functionCall, ControlFlowNode targetFunction
// 筛选条件：Python主版本为2，且调用的函数指向名为"apply"的内置函数
where 
    major_version() = 2 
    and functionCall.getFunction() = targetFunction 
    and targetFunction.pointsTo(Value::named("apply"))
// 选择符合条件的调用节点，并生成警告信息
select functionCall, "Call to the obsolete builtin function 'apply'."