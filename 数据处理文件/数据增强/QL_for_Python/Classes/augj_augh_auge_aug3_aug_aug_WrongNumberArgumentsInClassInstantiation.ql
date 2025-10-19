/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化调用时传递的参数数量与构造函数(__init__方法)期望的参数数量不符的情况。
 *               这种不匹配会导致运行时抛出TypeError异常，影响程序的健壮性。
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

from Call classInstantiation, ClassValue targetClass, string errorMsg, string constraintPrefix, int expectedCount, FunctionValue initMethod
where
  // 获取目标类的构造函数（通常是__init__方法）
  initMethod = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量不匹配的两种情况：过多或过少
    (
      too_many_args(classInstantiation, targetClass, expectedCount) and
      errorMsg = "too many arguments" and
      constraintPrefix = "no more than "
    )
    or
    (
      too_few_args(classInstantiation, targetClass, expectedCount) and
      errorMsg = "too few arguments" and
      constraintPrefix = "no fewer than "
    )
  )
select classInstantiation, "Call to $@ with " + errorMsg + "; should be " + constraintPrefix + expectedCount.toString() + ".", initMethod,
  // 输出调用点、错误消息及构造函数的完全限定名
  initMethod.getQualifiedName()