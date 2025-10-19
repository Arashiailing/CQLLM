/**
 * @name 类实例化参数数量错误
 * @description 在调用类的构造函数时传入的参数数量与定义不符，会引发运行时 TypeError 异常。
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

from Call invocation, ClassValue cls, string issueType, string limitPrefix, int paramLimit, FunctionValue initializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  initializer = get_function_or_initializer(cls) and
  (
    // 处理参数数量超出限制的情况
    too_many_args(invocation, cls, paramLimit) and
    issueType = "too many arguments" and
    limitPrefix = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(invocation, cls, paramLimit) and
    issueType = "too few arguments" and
    limitPrefix = "no fewer than "
  )
select invocation, "Call to $@ with " + issueType + "; should be " + limitPrefix + paramLimit.toString() + ".", initializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initializer.getQualifiedName()