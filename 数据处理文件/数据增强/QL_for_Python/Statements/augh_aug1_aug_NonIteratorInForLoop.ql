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

// 检测for循环中使用了不可迭代对象的潜在问题
from For forLoopStmt, ControlFlowNode iterationExprNode, Value targetValue, ClassValue targetClass, ControlFlowNode valueSourceLocation
where
  // 建立for循环与其迭代表达式之间的关联，并追踪到被迭代的值及其来源
  forLoopStmt.getIter().getAFlowNode() = iterationExprNode and
  iterationExprNode.pointsTo(_, targetValue, valueSourceLocation) and
  // 获取被迭代值的类类型，并验证它是有效的不可迭代类
  targetValue.getClass() = targetClass and
  not targetClass.isIterable() and
  not targetClass.failedInference(_) and
  // 排除特殊情况的误报：None值和描述符类型可能有特殊处理逻辑
  not (targetValue = Value::named("None") or targetClass.isDescriptorType())
select forLoopStmt, "This for-loop may attempt to iterate over a $@ of class $@.", valueSourceLocation,
  "non-iterable instance", targetClass, targetClass.getName()