/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的情况。当调用类的构造函数（通常是`__init__`方法）时，
 *              传入过多或过少的参数会导致运行时TypeError异常。
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

from Call classInstanceCall, ClassValue targetClass, string errorType, string requiredMessage, int expectedCount, FunctionValue initializerMethod
where
  (
    // 处理参数过多的情况
    too_many_args(classInstanceCall, targetClass, expectedCount) and
    errorType = "too many arguments" and
    requiredMessage = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(classInstanceCall, targetClass, expectedCount) and
    errorType = "too few arguments" and
    requiredMessage = "no fewer than "
  ) and
  // 获取目标类的初始化方法（通常是__init__）
  initializerMethod = get_function_or_initializer(targetClass)
select classInstanceCall, "Call to $@ with " + errorType + "; should be " + requiredMessage + expectedCount.toString() + ".", initializerMethod,
  initializerMethod.getQualifiedName()