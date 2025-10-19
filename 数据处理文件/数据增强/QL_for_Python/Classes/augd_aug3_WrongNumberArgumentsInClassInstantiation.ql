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

from Call classCall, ClassValue instantiatedClass, string errorType, string constraint, int expectedArgCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（构造函数）
  initMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量过多的情况
    too_many_args(classCall, instantiatedClass, expectedArgCount) and
    errorType = "too many arguments" and
    constraint = "no more than "
    or
    // 检查参数数量过少的情况
    too_few_args(classCall, instantiatedClass, expectedArgCount) and
    errorType = "too few arguments" and
    constraint = "no fewer than "
  )
select classCall, 
  "Call to $@ with " + errorType + "; should be " + constraint + expectedArgCount.toString() + ".", 
  initMethod,
  initMethod.getQualifiedName()