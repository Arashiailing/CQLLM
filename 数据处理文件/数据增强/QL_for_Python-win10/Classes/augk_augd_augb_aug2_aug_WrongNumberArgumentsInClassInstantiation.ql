/**
 * @name 类实例化参数数量不匹配
 * @description 识别类实例化时传递给构造函数 `__init__` 的参数数量不正确的情况。
 *              参数过多或不足都会在运行时引发 TypeError 异常。
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-685
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-number-class-arguments
 */

import python
import Expressions.CallArgs

from Call instanceCall, ClassValue targetClass, 
     string errorMsg, string constraintText, 
     int expectedArgCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（构造函数）
  initMethod = get_function_or_initializer(targetClass) and
  (
    // 检测参数数量超过预期的情况
    too_many_args(instanceCall, targetClass, expectedArgCount) and
    errorMsg = "too many arguments" and
    constraintText = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(instanceCall, targetClass, expectedArgCount) and
    errorMsg = "too few arguments" and
    constraintText = "no fewer than "
  )
select instanceCall, 
       "Call to $@ with " + errorMsg + "; should be " + constraintText + expectedArgCount.toString() + ".", 
       initMethod,
       // 返回类调用点、错误描述以及初始化方法的完全限定名称
       initMethod.getQualifiedName()