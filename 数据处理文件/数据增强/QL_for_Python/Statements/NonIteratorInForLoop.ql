/**
 * @name Non-iterable used in for loop
 * @description Using a non-iterable as the object in a 'for' loop causes a TypeError.
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

// 从For循环和控制流节点中提取迭代器、值、类值和原始节点
from For loop, ControlFlowNode iter, Value v, ClassValue t, ControlFlowNode origin
where
  // 获取循环的迭代器，并确保其指向的控制流节点是iter
  loop.getIter().getAFlowNode() = iter and
  // 确保iter指向某个值v，并且该值来自origin节点
  iter.pointsTo(_, v, origin) and
  // 获取值v的类类型t
  v.getClass() = t and
  // 确保类类型t不是可迭代对象
  not t.isIterable() and
  // 确保类类型t没有失败的类型推断
  not t.failedInference(_) and
  // 确保值v不是None
  not v = Value::named("None") and
  // 确保类类型t不是描述符类型
  not t.isDescriptorType()
select loop, "This for-loop may attempt to iterate over a $@ of class $@.", origin,
  // 选择循环和原始节点，并报告可能尝试在非可迭代对象上进行迭代的问题
  "non-iterable instance", t, t.getName()
