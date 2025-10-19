/**
 * @name Non-callable called
 * @description Detects code that attempts to invoke non-callable objects,
 *              which would cause a TypeError at runtime.
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

// 定义变量：调用表达式、目标值、目标类、函数引用和源节点
from Call callExpr, Value targetValue, ClassValue targetClass, Expr funcReference, AstNode sourceNode
where
  // 第一部分：建立调用表达式与目标值的关联
  funcReference = callExpr.getFunc() and
  funcReference.pointsTo(targetValue, sourceNode) and
  
  // 第二部分：验证目标值的不可调用性
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 第三部分：排除误报情况
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcReference)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()