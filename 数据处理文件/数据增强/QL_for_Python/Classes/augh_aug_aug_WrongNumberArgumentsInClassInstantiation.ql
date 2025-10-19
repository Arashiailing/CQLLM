/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与构造函数(`__init__`)定义不匹配的情况。
 *              这种不匹配会导致运行时TypeError异常，影响程序可靠性。
 *              修复建议：检查类实例化调用，确保参数数量与构造函数定义一致。
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

from Call invocation, ClassValue instantiatedClass, string errorType, string constraintPrefix, int expectedArgCount, FunctionValue constructorMethod
where
  // 获取目标类的构造方法（即__init__方法）
  constructorMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量超过上限的情况
    too_many_args(invocation, instantiatedClass, expectedArgCount) and
    errorType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(invocation, instantiatedClass, expectedArgCount) and
    errorType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocation, "Call to $@ with " + errorType + "; should be " + constraintPrefix + expectedArgCount.toString() + ".", constructorMethod,
  // 输出调用点、错误消息及构造方法的完全限定名
  constructorMethod.getQualifiedName()