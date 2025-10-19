/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时提供给 `__init__` 方法的参数数量与定义不符的情况，
 *              这种不匹配会导致运行时抛出 TypeError 异常。
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

from Call callNode, ClassValue targetClass, string issueType, string constraintType, int expectedCount, FunctionValue initializer
where
  // 获取目标类的初始化方法（__init__）
  initializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量过多的情况
    too_many_args(callNode, targetClass, expectedCount) and
    issueType = "too many arguments" and
    constraintType = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(callNode, targetClass, expectedCount) and
    issueType = "too few arguments" and
    constraintType = "no fewer than "
  )
select callNode, "Call to $@ with " + issueType + "; should be " + constraintType + expectedCount.toString() + ".", initializer,
  initializer.getQualifiedName()