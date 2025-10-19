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

// 检测在for循环中使用不可迭代对象的情况，这些对象在运行时会导致TypeError异常
from For forStmt, ControlFlowNode iterNode, Value targetValue, ClassValue targetClass, ControlFlowNode originNode
where
  // 关联for循环语句与其迭代器表达式节点
  forStmt.getIter().getAFlowNode() = iterNode and
  
  // 追溯迭代器节点指向的值及其来源位置
  iterNode.pointsTo(_, targetValue, originNode) and
  
  // 获取被迭代值的类类型并确认其不具备可迭代性
  targetValue.getClass() = targetClass and
  not targetClass.isIterable() and
  
  // 排除可能导致误报的特殊情况
  not targetClass.failedInference(_) and  // 类型推断成功的类
  not targetValue = Value::named("None") and  // 非None值
  not targetClass.isDescriptorType()  // 非描述符类型
select forStmt, "This for-loop may attempt to iterate over a $@ of class $@.", originNode,
  "non-iterable instance", targetClass, targetClass.getName()