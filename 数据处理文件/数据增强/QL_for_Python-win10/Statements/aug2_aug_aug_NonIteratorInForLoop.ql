/**
 * @name Non-iterable used in for loop
 * @description Identifies for-loops that iterate over non-iterable objects, which would raise a TypeError at runtime.
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

// 查找在for循环中误用不可迭代对象的代码模式
from For loopStatement, ControlFlowNode iteratorNode, Value iteratedValue, ClassValue valueClass, ControlFlowNode sourceNode
where
  // 关联for循环语句与对应的迭代器节点
  loopStatement.getIter().getAFlowNode() = iteratorNode and
  // 通过数据流分析追踪迭代器节点引用的值及其来源
  iteratorNode.pointsTo(_, iteratedValue, sourceNode) and
  // 获取被迭代值的类类型
  iteratedValue.getClass() = valueClass and
  // 确认该类类型不具备可迭代特性
  not valueClass.isIterable() and
  // 排除可能导致误报的特殊情况
  not valueClass.failedInference(_) and  // 确保类型推断成功
  not iteratedValue = Value::named("None") and  // 排除None值
  not valueClass.isDescriptorType()  // 排除描述符类型
select loopStatement, "This for-loop may attempt to iterate over a $@ of class $@.", sourceNode,
  "non-iterable instance", valueClass, valueClass.getName()