/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的问题。当调用类的 `__init__` 方法时，
 *              传入过多或过少的参数会导致运行时 TypeError 异常。
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

from Call classInstantiation, ClassValue targetClass, string errorType, string constraintType, int expectedParamCount, FunctionValue initializerMethod
where
  // 获取目标类的初始化方法（__init__ 或构造函数）
  initializerMethod = get_function_or_initializer(targetClass) and
  (
    // 检测参数数量超过限制的情况
    too_many_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too many arguments" and
    constraintType = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too few arguments" and
    constraintType = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + errorType + "; should be " + constraintType + expectedParamCount.toString() + ".", initializerMethod,
  initializerMethod.getQualifiedName()