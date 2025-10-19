/**
 * @name Non-callable called
 * @description Identifies code that attempts to call objects which are not callable,
 *              resulting in a TypeError exception at runtime.
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

// 定义查询变量：调用表达式、目标值、目标类、函数表达式和源节点
from Call callExpr, Value targetValue, ClassValue targetClass, Expr funcExpr, AstNode sourceNode
where
  // 第一部分：识别调用表达式及其目标函数
  funcExpr = callExpr.getFunc() and
  funcExpr.pointsTo(targetValue, sourceNode) and
  
  // 第二部分：验证目标值的类不可调用
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 第三部分：排除误报情况
  // 确保类型推断成功且类没有__get__属性
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  
  // 排除None值和在raise语句中使用NotImplemented的特殊情况
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcExpr)
select callExpr, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()