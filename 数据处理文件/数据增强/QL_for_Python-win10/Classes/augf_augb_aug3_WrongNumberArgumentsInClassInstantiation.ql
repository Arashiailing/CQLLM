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

from Call classCall, ClassValue targetClass, string issueType, string constraintText, int expectedCount, FunctionValue initializer
where
  // 获取目标类的初始化方法（__init__ 或构造函数）
  initializer = get_function_or_initializer(targetClass) and
  (
    // 检测参数数量超过预期的情况
    too_many_args(classCall, targetClass, expectedCount) and
    issueType = "too many arguments" and
    constraintText = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classCall, targetClass, expectedCount) and
    issueType = "too few arguments" and
    constraintText = "no fewer than "
  )
select classCall, "Call to $@ with " + issueType + "; should be " + constraintText + expectedCount.toString() + ".", initializer,
  initializer.getQualifiedName()