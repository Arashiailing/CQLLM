/**
 * @name Non-iterable used in for loop
 * @description This query detects for loops that attempt to iterate over non-iterable objects, which would cause a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/non-iterable-in-for-loop
 */

import python

// 查找for循环中使用的非可迭代对象
from For forStmt, ControlFlowNode iteratorNode, Value targetValue, ClassValue targetType, ControlFlowNode valueSource
where
  // 关联for循环与其迭代器节点
  forStmt.getIter().getAFlowNode() = iteratorNode and
  // 追溯迭代器节点到其源值和源节点
  iteratorNode.pointsTo(_, targetValue, valueSource) and
  // 获取被迭代值的类类型
  targetValue.getClass() = targetType and
  // 检查类类型是否不可迭代
  not targetType.isIterable() and
  // 排除类型推断失败的情况
  not targetType.failedInference(_) and
  // 排除None值（None在Python中不是可迭代的，但通常不是错误）
  not targetValue = Value::named("None") and
  // 排除描述符类型（这些类型可能具有特殊行为）
  not targetType.isDescriptorType()
select forStmt, "This for-loop may attempt to iterate over a $@ of class $@.", valueSource,
  "non-iterable instance", targetType, targetType.getName()