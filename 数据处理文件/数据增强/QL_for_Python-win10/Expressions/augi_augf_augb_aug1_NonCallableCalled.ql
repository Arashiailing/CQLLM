/**
 * @name Non-callable called
 * @description Detects code locations where non-callable objects are invoked as functions,
 *              leading to runtime TypeError exceptions. This query identifies potential
 *              bugs where objects that do not support the function call protocol are
 *              incorrectly used as functions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python  // 导入Python分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义变量：函数调用、被调用对象、对象类、函数表达式和源节点
from Call funcCall, Value callee, ClassValue objectClass, Expr calleeRef, AstNode originNode
where
  // 获取函数调用中的函数表达式及其指向的值
  calleeRef = funcCall.getFunc() and
  calleeRef.pointsTo(callee, originNode) and
  
  // 检查被调用对象的类是否不可调用
  objectClass = callee.getClass() and
  not objectClass.isCallable() and
  
  // 确保类型推断成功且类没有__get__属性
  not objectClass.failedInference(_) and
  not objectClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not callee = Value::named("None") and
  not use_of_not_implemented_in_raise(_, calleeRef)
select funcCall, "Call to a $@ of $@.", originNode, "non-callable", objectClass, objectClass.toString()