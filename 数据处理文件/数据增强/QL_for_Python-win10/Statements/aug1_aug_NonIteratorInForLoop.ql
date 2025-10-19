/**
 * @name Non-iterable used in for loop
 * @description Detects for loops that attempt to iterate over non-iterable objects, which would cause a TypeError at runtime.
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

// 查找在for循环中使用的非可迭代对象
from For loopStatement, ControlFlowNode iterExprNode, Value iteratedValue, ClassValue iteratedClass, ControlFlowNode sourceLocation
where
  // 关联for循环与其迭代表达式节点，并追溯到被迭代的值和源位置
  loopStatement.getIter().getAFlowNode() = iterExprNode and
  iterExprNode.pointsTo(_, iteratedValue, sourceLocation) and
  // 获取被迭代值的类类型，并确保它是有效的不可迭代类（排除推断失败的情况）
  iteratedValue.getClass() = iteratedClass and
  not iteratedClass.isIterable() and
  not iteratedClass.failedInference(_) and
  // 排除特殊情况：None值和描述符类型，它们可能有特殊处理或不是真正的错误
  not (iteratedValue = Value::named("None") or iteratedClass.isDescriptorType())
select loopStatement, "This for-loop may attempt to iterate over a $@ of class $@.", sourceLocation,
  "non-iterable instance", iteratedClass, iteratedClass.getName()