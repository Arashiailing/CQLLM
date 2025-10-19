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

// 查找所有调用不可调用对象的情况
from Call callExpr, Value targetValue, ClassValue targetClass, Expr callee, AstNode sourceNode
where
  // 识别调用表达式和被调用者
  callee = callExpr.getFunc() and
  callee.pointsTo(targetValue, sourceNode) and
  
  // 分析被调用者引用的值和其类
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 排除特殊情况
  // 确保类型推断成功
  not targetClass.failedInference(_) and
  // 排除有__get__属性的类（可能是描述符）
  not targetClass.hasAttribute("__get__") and
  // 排除None值
  not targetValue = Value::named("None") and
  // 排除在raise语句中使用NotImplemented的情况
  not use_of_not_implemented_in_raise(_, callee)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()