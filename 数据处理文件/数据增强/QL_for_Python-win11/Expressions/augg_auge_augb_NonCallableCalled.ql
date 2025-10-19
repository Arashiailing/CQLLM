/**
 * @name Invocation of Non-Callable Objects
 * @description Identifies code locations where non-callable objects are invoked, which would lead to a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python
import Exceptions.NotImplemented

// 查找所有调用非可调用对象的代码位置
from Call callSite, Value targetObject, ClassValue targetClass, Expr invokedExpression, AstNode originNode
where
  // 获取调用表达式及其指向的值
  invokedExpression = callSite.getFunc() and
  invokedExpression.pointsTo(targetObject, originNode) and
  
  // 确定目标值的类并验证其不可调用性
  targetClass = targetObject.getClass() and
  not targetClass.isCallable() and
  
  // 排除特殊情况以减少误报
  not targetClass.failedInference(_) and  // 确保类型推断成功
  not targetClass.hasAttribute("__get__") and  // 排除描述符协议对象
  not targetObject = Value::named("None") and  // 排除对None的调用
  not use_of_not_implemented_in_raise(_, invokedExpression)  // 排除raise语句中的NotImplemented
select callSite, "Call to a $@ of $@.", originNode, "non-callable", targetClass, targetClass.toString()