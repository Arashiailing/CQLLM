/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时传递给 `__init__` 方法的参数数量与定义不符的情况，这会在运行时引发 TypeError 异常。
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

from Call invocationPoint, ClassValue instantiatedClass, string argumentIssue, string limitDescription, int parameterThreshold, FunctionValue initializerMethod
where
  // 获取目标类的初始化方法（__init__或构造函数）
  initializerMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 处理参数过多的情况
    too_many_args(invocationPoint, instantiatedClass, parameterThreshold) and
    argumentIssue = "too many arguments" and
    limitDescription = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(invocationPoint, instantiatedClass, parameterThreshold) and
    argumentIssue = "too few arguments" and
    limitDescription = "no fewer than "
  )
select invocationPoint, "Call to $@ with " + argumentIssue + "; should be " + limitDescription + parameterThreshold.toString() + ".", initializerMethod,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initializerMethod.getQualifiedName()