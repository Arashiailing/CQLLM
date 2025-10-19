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
from For loopStatement, ControlFlowNode iterExprNode, Value iteratedValue, ClassValue iteratedClass, ControlFlowNode valueSource
where
  // 关联for循环与其迭代表达式节点，并获取被迭代的值及其来源
  loopStatement.getIter().getAFlowNode() = iterExprNode and
  iterExprNode.pointsTo(_, iteratedValue, valueSource) and
  
  // 确定被迭代值的类类型，并验证其不可迭代性
  iteratedValue.getClass() = iteratedClass and
  not iteratedClass.isIterable() and
  not iteratedClass.failedInference(_) and
  
  // 排除已知特殊情况，以减少误报
  not (iteratedValue = Value::named("None") or iteratedClass.isDescriptorType())
select loopStatement, "This for-loop may attempt to iterate over a $@ of class $@.", valueSource,
  "non-iterable instance", iteratedClass, iteratedClass.getName()