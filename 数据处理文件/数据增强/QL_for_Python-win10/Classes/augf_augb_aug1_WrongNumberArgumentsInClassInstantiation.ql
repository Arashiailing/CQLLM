/**
 * @name 类实例化参数数量错误
 * @description 检测类实例化时参数数量不匹配的问题。当调用类的构造函数时，
 *              如果传入的参数数量与定义不符，会导致运行时 TypeError 异常。
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

from Call newInstanceCall, ClassValue targetClass, string errorType, string requirementPrefix, int allowedArgCount, FunctionValue constructorMethod
where
  (
    // 处理参数数量过多的情况
    too_many_args(newInstanceCall, targetClass, allowedArgCount) and
    errorType = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(newInstanceCall, targetClass, allowedArgCount) and
    errorType = "too few arguments" and
    requirementPrefix = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  constructorMethod = get_function_or_initializer(targetClass)
select newInstanceCall, "Call to $@ with " + errorType + "; should be " + requirementPrefix + allowedArgCount.toString() + ".", constructorMethod,
  constructorMethod.getQualifiedName()