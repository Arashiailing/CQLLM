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

// 定义查询变量：调用表达式、被调用值、被调用值的类、函数表达式和值来源
from Call invocation, Value invokedValue, ClassValue invokedClass, Expr funcRef, AstNode valOrigin
where
  // 步骤1：识别调用表达式及其引用的函数
  funcRef = invocation.getFunc() and
  funcRef.pointsTo(invokedValue, valOrigin) and
  
  // 步骤2：验证被调用值的类不可调用
  invokedClass = invokedValue.getClass() and
  not invokedClass.isCallable() and
  
  // 步骤3：过滤掉已知的误报情况
  (
    // 确保类型推断成功
    not invokedClass.failedInference(_) and
    // 排除描述符对象（有__get__属性的对象）
    not invokedClass.hasAttribute("__get__") and
    // 排除None值
    not invokedValue = Value::named("None") and
    // 排除在raise语句中使用NotImplemented的情况
    not use_of_not_implemented_in_raise(_, funcRef)
  )
select invocation, "Call to a $@ of $@.", valOrigin, "non-callable", invokedClass, invokedClass.toString()