/**
 * @name Non-iterable used in for loop
 * @description Identifies for loops that attempt to iterate over objects that are not iterable,
 *              which would result in a TypeError at runtime.
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
from For forLoop, ControlFlowNode iterationExprNode, Value targetValue, ClassValue targetClass, ControlFlowNode valueSource
where
  // 建立for循环与其迭代表达式节点之间的关联
  forLoop.getIter().getAFlowNode() = iterationExprNode
  and
  // 从迭代表达式节点追溯到被迭代的值及其源位置
  iterationExprNode.pointsTo(_, targetValue, valueSource)
  and
  // 获取被迭代值的类类型
  targetValue.getClass() = targetClass
  and
  // 确保类是不可迭代的
  not targetClass.isIterable()
  and
  // 排除类型推断失败的情况
  not targetClass.failedInference(_)
  and
  // 排除特殊情况：None值和描述符类型
  not (targetValue = Value::named("None") or targetClass.isDescriptorType())
select forLoop, "This for-loop may attempt to iterate over a $@ of class $@.", valueSource,
  "non-iterable instance", targetClass, targetClass.getName()