/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与构造函数（__init__方法）定义不匹配的情况。
 *              这类问题会在运行时导致TypeError异常，影响程序可靠性。
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

from Call instantiationCall, ClassValue targetClass, string errorDescription, string constraintMessage, int expectedCount, FunctionValue constructorFunction
where
  // 获取目标类的构造函数（通常是__init__方法）
  constructorFunction = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超过上限的情况
    too_many_args(instantiationCall, targetClass, expectedCount) and
    errorDescription = "too many arguments" and
    constraintMessage = "no more than "
    or
    // 处理参数数量低于下限的情况
    too_few_args(instantiationCall, targetClass, expectedCount) and
    errorDescription = "too few arguments" and
    constraintMessage = "no fewer than "
  )
select instantiationCall, "Call to $@ with " + errorDescription + "; should be " + constraintMessage + expectedCount.toString() + ".", constructorFunction,
  // 输出调用点、错误消息及构造函数的完全限定名
  constructorFunction.getQualifiedName()