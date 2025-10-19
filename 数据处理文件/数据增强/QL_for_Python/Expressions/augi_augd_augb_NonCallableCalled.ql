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

import python  // 导入Python代码分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义查询变量：调用表达式、目标值、目标类、函数引用和值来源
from Call callExpr, Value targetValue, ClassValue targetClass, Expr functionReference, AstNode valueOrigin
where
  // 步骤1：获取调用表达式及其引用的函数
  functionReference = callExpr.getFunc() and
  functionReference.pointsTo(targetValue, valueOrigin) and
  
  // 步骤2：确定目标值的类并验证其不可调用性
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 步骤3：排除已知的误报情况
  (
    // 确保类型推断成功
    not targetClass.failedInference(_) and
    // 排除描述符对象（有__get__属性的对象）
    not targetClass.hasAttribute("__get__") and
    // 排除None值
    not targetValue = Value::named("None") and
    // 排除在raise语句中使用NotImplemented的情况
    not use_of_not_implemented_in_raise(_, functionReference)
  )
select callExpr, "Call to a $@ of $@.", valueOrigin, "non-callable", targetClass, targetClass.toString()