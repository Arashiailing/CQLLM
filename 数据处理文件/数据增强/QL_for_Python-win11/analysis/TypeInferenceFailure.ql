/**
 * @name Type inference fails for 'object'
 * @description Type inference fails for 'object' which reduces recall for many queries.
 * @kind problem
 * @problem.severity info
 * @id py/type-inference-failure
 * @deprecated
 */

// 导入Python库，用于处理Python代码的查询
import python

// 从ControlFlowNode和Object类中选择数据
from ControlFlowNode f, Object o
where
  // 过滤条件：f引用了o
  f.refersTo(o) and
  // 并且f没有通过其他方式引用o
  not f.refersTo(o, _, _)
// 选择对象o，并返回信息“Type inference fails for 'object'.”
select o, "Type inference fails for 'object'."
