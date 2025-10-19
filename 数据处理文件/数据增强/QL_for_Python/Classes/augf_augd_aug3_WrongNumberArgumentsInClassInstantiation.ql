/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时提供给 `__init__` 方法的参数数量与定义不符的情况，
 *              这种情况会导致运行时 TypeError 异常。
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

from Call classInstantiation, ClassValue targetClass, string errorMessage, string constraintType, int expectedArgumentCount, FunctionValue initializerMethod
where
  // 获取目标类的初始化方法（构造函数）
  initializerMethod = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量过多的情况
    too_many_args(classInstantiation, targetClass, expectedArgumentCount) and
    errorMessage = "too many arguments" and
    constraintType = "no more than "
    or
    // 处理参数数量过少的情况
    too_few_args(classInstantiation, targetClass, expectedArgumentCount) and
    errorMessage = "too few arguments" and
    constraintType = "no fewer than "
  )
select classInstantiation, 
  "Call to $@ with " + errorMessage + "; should be " + constraintType + expectedArgumentCount.toString() + ".", 
  initializerMethod,
  initializerMethod.getQualifiedName()