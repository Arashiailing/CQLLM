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

from Call invocation, ClassValue classType, string argumentIssue, string expectedRequirement, int argumentLimit, FunctionValue initializer
where
  // 获取类的构造函数或初始化方法
  initializer = get_function_or_initializer(classType) and
  (
    // 检查参数过多的情况
    too_many_args(invocation, classType, argumentLimit) and
    argumentIssue = "too many arguments" and
    expectedRequirement = "no more than "
    or
    // 检查参数过少的情况
    too_few_args(invocation, classType, argumentLimit) and
    argumentIssue = "too few arguments" and
    expectedRequirement = "no fewer than "
  )
select invocation, "Call to $@ with " + argumentIssue + "; should be " + expectedRequirement + argumentLimit.toString() + ".", initializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initializer.getQualifiedName()