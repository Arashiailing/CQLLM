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
from For forStmt, ControlFlowNode iterationExprNode, Value targetValue, ClassValue targetClass, ControlFlowNode valueOrigin
where
  // 步骤1：关联for循环与其迭代表达式节点，并追溯到被迭代的值和源位置
  forStmt.getIter().getAFlowNode() = iterationExprNode and
  iterationExprNode.pointsTo(_, targetValue, valueOrigin) and
  
  // 步骤2：获取被迭代值的类类型，并验证其不可迭代性
  targetValue.getClass() = targetClass and
  not targetClass.isIterable() and
  not targetClass.failedInference(_) and
  
  // 步骤3：排除特殊情况，避免误报
  not (targetValue = Value::named("None") or targetClass.isDescriptorType())
select forStmt, "This for-loop may attempt to iterate over a $@ of class $@.", valueOrigin,
  "non-iterable instance", targetClass, targetClass.getName()