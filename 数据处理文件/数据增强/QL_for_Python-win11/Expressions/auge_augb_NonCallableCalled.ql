/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would result in a TypeError at runtime.
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
from Call invocationNode, Value calledValue, ClassValue calledClass, Expr functionExpr, AstNode valueSource
where
  // 获取调用表达式及其指向的值
  functionExpr = invocationNode.getFunc() and
  functionExpr.pointsTo(calledValue, valueSource) and
  
  // 确定目标值的类并验证其不可调用性
  calledClass = calledValue.getClass() and
  not calledClass.isCallable() and
  
  // 排除特殊情况以减少误报
  not calledClass.failedInference(_) and  // 确保类型推断成功
  not calledClass.hasAttribute("__get__") and  // 排除描述符协议对象
  not calledValue = Value::named("None") and  // 排除对None的调用
  not use_of_not_implemented_in_raise(_, functionExpr)  // 排除raise语句中的NotImplemented
select invocationNode, "Call to a $@ of $@.", valueSource, "non-callable", calledClass, calledClass.toString()