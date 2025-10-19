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

from Call callExpr, ClassValue cls, string issueType, string requirement, int expectedCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（构造函数）
  initMethod = get_function_or_initializer(cls) and
  (
    // 处理参数过多的情况
    too_many_args(callExpr, cls, expectedCount) and
    issueType = "too many arguments" and
    requirement = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(callExpr, cls, expectedCount) and
    issueType = "too few arguments" and
    requirement = "no fewer than "
  )
select callExpr, "Call to $@ with " + issueType + "; should be " + requirement + expectedCount.toString() + ".", initMethod,
  initMethod.getQualifiedName()