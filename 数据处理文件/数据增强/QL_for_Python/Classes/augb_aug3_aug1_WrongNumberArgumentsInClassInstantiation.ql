/**
 * @name 错误的类实例化参数数量
 * @description 识别类实例化过程中参数数量不匹配的情况。当调用类的构造函数时，
 *              如果提供的参数数量与预期不符，将导致运行时 TypeError 异常。
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
  // 获取目标类的初始化方法
  initializerMethod = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超过限制的情况
    too_many_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too many arguments" and
    constraintType = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too few arguments" and
    constraintType = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + errorType + "; should be " + constraintType + expectedParamCount.toString() + ".", initializerMethod,
  initializerMethod.getQualifiedName()