/**
 * @name 类实例化参数数量不匹配
 * @description 当实例化类时，若传递给 `__init__` 方法的参数数量与定义不符，
 *              将会在运行时引发 TypeError 异常。
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

from Call methodCall, ClassValue targetClass, string errorType, string limitPrefix, int argCountLimit, FunctionValue initMethod
where
  // 首先获取目标类的初始化方法
  initMethod = get_function_or_initializer(targetClass) and
  (
    // 检查参数数量超过上限的情况
    too_many_args(methodCall, targetClass, argCountLimit) and
    errorType = "too many arguments" and
    limitPrefix = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(methodCall, targetClass, argCountLimit) and
    errorType = "too few arguments" and
    limitPrefix = "no fewer than "
  )
select methodCall, "Call to $@ with " + errorType + "; should be " + limitPrefix + argCountLimit.toString() + ".", initMethod,
  // 返回调用节点、错误描述以及初始化方法的完整限定名
  initMethod.getQualifiedName()