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
 * @id py/call-to-non-callable */

import python
import Exceptions.NotImplemented

// 定义核心变量：调用表达式、目标值、目标类、函数引用和源节点
from Call invocation, Value referencedValue, ClassValue valueClass, 
     Expr calledFunction, AstNode originNode
where
  // 获取调用表达式中的函数引用及其指向的值
  calledFunction = invocation.getFunc() and
  calledFunction.pointsTo(referencedValue, originNode) and
  
  // 分析目标值的类特征
  valueClass = referencedValue.getClass() and
  not valueClass.isCallable() and
  not valueClass.failedInference(_) and
  
  // 排除特殊协议对象和特定值
  not valueClass.hasAttribute("__get__") and
  not referencedValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, calledFunction)
select invocation, "Call to a $@ of $@.", originNode, "non-callable", valueClass, valueClass.toString()