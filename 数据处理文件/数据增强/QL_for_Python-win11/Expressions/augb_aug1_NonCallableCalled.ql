/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would raise a TypeError at runtime.
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
from Call invocationExpr, Value calledValue, ClassValue calledClass, Expr functionRef, AstNode originNode
where
  // 获取调用表达式中的函数引用及其指向的值
  functionRef = invocationExpr.getFunc() and
  functionRef.pointsTo(calledValue, originNode) and
  
  // 检查被调用值的类是否不可调用
  calledClass = calledValue.getClass() and
  not calledClass.isCallable() and
  
  // 确保类型推断成功且类没有__get__属性
  not calledClass.failedInference(_) and
  not calledClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not calledValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionRef)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", calledClass, calledClass.toString()