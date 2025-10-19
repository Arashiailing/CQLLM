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

import python  // 导入Python分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义变量：调用表达式、目标值、目标类、函数引用和源节点
from Call callExpr, Value targetValue, ClassValue targetClass, Expr funcRef, AstNode sourceNode
where
  // 获取调用表达式中的函数引用及其指向的值
  funcRef = callExpr.getFunc() and
  funcRef.pointsTo(targetValue, sourceNode) and
  
  // 检查目标值的类是否不可调用且类型推断成功
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  not targetClass.failedInference(_) and
  
  // 排除具有__get__属性的类（描述符协议相关）
  not targetClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcRef)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()