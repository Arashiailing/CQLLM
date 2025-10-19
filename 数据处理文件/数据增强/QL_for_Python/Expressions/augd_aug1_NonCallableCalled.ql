/**
 * @name Non-callable called
 * @description Identifies code that attempts to invoke non-callable objects, 
 *              which would result in a TypeError during execution.
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

// 定义变量：调用表达式、被调用值、被调用类、函数引用和源节点
from Call invocationExpr, Value calleeValue, ClassValue calleeClass, Expr functionRef, AstNode originNode
where
  // 获取调用表达式中的函数引用并追踪其指向的值
  functionRef = invocationExpr.getFunc() and
  functionRef.pointsTo(calleeValue, originNode) and
  
  // 确定被调用值的类并验证其不可调用性
  calleeClass = calleeValue.getClass() and
  not calleeClass.isCallable() and
  
  // 排除特殊情况：类型推断失败、具有__get__属性、值为None或在raise语句中使用NotImplemented
  not calleeClass.failedInference(_) and
  not calleeClass.hasAttribute("__get__") and
  not calleeValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionRef)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", calleeClass, calleeClass.toString()