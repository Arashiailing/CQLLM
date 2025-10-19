/**
 * @name 错误的类实例化参数数量
 * @description 检测在调用类构造函数时传入参数数量不匹配的情况，
 *              包括参数过多或过少，这些情况会导致运行时 TypeError。
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

from Call classInvocation, ClassValue targetClass, string errorType, string requirementPrefix, int expectedCount, FunctionValue constructorMethod
where
  (
    // 处理参数数量超过上限的情况
    too_many_args(classInvocation, targetClass, expectedCount) and
    errorType = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 处理参数数量不足下限的情况
    too_few_args(classInvocation, targetClass, expectedCount) and
    errorType = "too few arguments" and
    requirementPrefix = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  constructorMethod = get_function_or_initializer(targetClass)
select classInvocation, "Call to $@ with " + errorType + "; should be " + requirementPrefix + expectedCount.toString() + ".", constructorMethod,
  // 返回调用节点、错误描述以及初始化方法的完整名称
  constructorMethod.getQualifiedName()