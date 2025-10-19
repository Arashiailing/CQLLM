/**
 * @name 类实例化参数数量错误
 * @description 识别类实例化时提供的参数数量与其构造函数(`__init__`方法)所期望的参数数量不匹配的情况，
 *              这种不匹配会在运行时引发TypeError异常。
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

from Call invocationPoint, ClassValue instantiatedClass, string errorType, string constraintPrefix, int expectedArgCount, FunctionValue constructorMethod
where
  // 获取被实例化类的构造函数
  constructorMethod = get_function_or_initializer(instantiatedClass) and
  // 确定参数数量错误类型并设置相应的约束前缀
  (
    // 处理参数数量超过上限的情况
    too_many_args(invocationPoint, instantiatedClass, expectedArgCount) and
    errorType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 处理参数数量低于下限的情况
    too_few_args(invocationPoint, instantiatedClass, expectedArgCount) and
    errorType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocationPoint, "Call to $@ with " + errorType + "; should be " + constraintPrefix + expectedArgCount.toString() + ".", constructorMethod,
  // 输出调用点、错误消息及构造方法的完全限定名
  constructorMethod.getQualifiedName()