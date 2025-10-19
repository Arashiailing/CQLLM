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

// 定义变量：调用表达式、目标值、目标类、函数表达式和源节点
from Call callExpr, Value targetValue, ClassValue targetClass, Expr funcExpr, AstNode sourceNode
where
  // 获取调用的函数表达式并确定其指向的值
  funcExpr = callExpr.getFunc() and
  funcExpr.pointsTo(targetValue, sourceNode) and
  
  // 获取值所属的类并检查其可调用性
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 确保类型推断成功且类没有__get__属性
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcExpr)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()