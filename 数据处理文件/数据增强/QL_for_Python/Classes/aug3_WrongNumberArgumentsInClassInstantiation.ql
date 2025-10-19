/**
 * @name 类构造函数参数数量不匹配
 * @description 当实例化类时，如果提供给 `__init__` 方法的参数数量与定义不符，会引发运行时 TypeError 异常。
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

from Call invocation, ClassValue targetClass, string issueType, string requirement, int expectedCount, FunctionValue initializer
where
  // 获取类的构造函数或初始化方法
  initializer = get_function_or_initializer(targetClass) and
  (
    // 检查是否传递了过多的参数
    too_many_args(invocation, targetClass, expectedCount) and
    issueType = "too many arguments" and
    requirement = "no more than "
    or
    // 检查是否传递了过少的参数
    too_few_args(invocation, targetClass, expectedCount) and
    issueType = "too few arguments" and
    requirement = "no fewer than "
  )
select invocation, "Call to $@ with " + issueType + "; should be " + requirement + expectedCount.toString() + ".", initializer,
  initializer.getQualifiedName()