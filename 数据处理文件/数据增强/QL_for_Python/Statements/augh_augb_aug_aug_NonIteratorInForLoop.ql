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

// 检测在for循环中使用不可迭代对象的情况，这将在运行时引发TypeError异常
from For forStmt, ControlFlowNode iterExprNode, Value iteratedObj, ClassValue objClass, ControlFlowNode originNode
where
  // 关联for循环语句与其迭代表达式节点
  forStmt.getIter().getAFlowNode() = iterExprNode and
  // 追溯迭代表达式节点指向的值及其来源位置
  iterExprNode.pointsTo(_, iteratedObj, originNode) and
  // 获取被迭代对象的类类型并检查其不可迭代性
  iteratedObj.getClass() = objClass and
  not objClass.isIterable() and
  // 排除可能导致误报的特殊情况
  not objClass.failedInference(_) and  // 确保类型推断成功
  not iteratedObj = Value::named("None") and  // 排除None值
  not objClass.isDescriptorType()  // 排除描述符类型
select forStmt, "This for-loop may attempt to iterate over a $@ of class $@.", originNode,
  "non-iterable instance", objClass, objClass.getName()