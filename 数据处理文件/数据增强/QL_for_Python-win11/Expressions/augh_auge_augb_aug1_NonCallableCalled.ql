/**
 * @name Non-callable called
 * @description Identifies runtime TypeError scenarios where non-callable objects are invoked
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable */

import python  // 导入Python分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义变量：调用表达式、目标对象、对象类、函数引用和源节点
from Call invocation, Value calledObject, ClassValue objectClass, Expr functionReference, AstNode originNode
where
  // 获取调用表达式中的函数引用及其指向的值
  functionReference = invocation.getFunc() and
  functionReference.pointsTo(calledObject, originNode) and
  
  // 验证目标对象的类不可调用且类型推断成功
  objectClass = calledObject.getClass() and
  not objectClass.isCallable() and
  not objectClass.failedInference(_) and
  
  // 排除描述符协议相关对象（具有__get__属性）
  not objectClass.hasAttribute("__get__") and
  
  // 排除特定场景：None值和raise语句中的NotImplemented
  not calledObject = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionReference)
select invocation, "Call to a $@ of $@.", originNode, "non-callable", objectClass, objectClass.toString()