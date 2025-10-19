/**
 * @name 错误的类实例化参数数量
 * @description 类的 `__init__` 方法调用时传入参数数量不匹配，会导致运行时 TypeError 异常。
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

from Call invocationPoint, ClassValue instantiatedClass, string argumentIssue, string limitDescriptionPrefix, int parameterCountThreshold, FunctionValue constructorFunction
where
  // 获取目标类的初始化方法（构造函数）
  constructorFunction = get_function_or_initializer(instantiatedClass) and
  (
    // 检测参数数量过多的情况
    too_many_args(invocationPoint, instantiatedClass, parameterCountThreshold) and
    argumentIssue = "too many arguments" and
    limitDescriptionPrefix = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(invocationPoint, instantiatedClass, parameterCountThreshold) and
    argumentIssue = "too few arguments" and
    limitDescriptionPrefix = "no fewer than "
  )
select invocationPoint, "Call to $@ with " + argumentIssue + "; should be " + limitDescriptionPrefix + parameterCountThreshold.toString() + ".", constructorFunction,
  // 输出调用点、错误消息及初始化方法的完全限定名
  constructorFunction.getQualifiedName()