/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的问题。当调用类的 `__init__` 方法时，
 *              传入过多或过少的参数会导致运行时 TypeError 异常。
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

from Call instanceCreation, ClassValue instantiatedClass, string errorKind, string constraint, int parameterCount, FunctionValue initMethod
where
  // 获取目标类的构造函数或初始化方法
  initMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 检测参数数量超过限制的情况
    too_many_args(instanceCreation, instantiatedClass, parameterCount) and
    errorKind = "too many arguments" and
    constraint = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(instanceCreation, instantiatedClass, parameterCount) and
    errorKind = "too few arguments" and
    constraint = "no fewer than "
  )
select instanceCreation, "Call to $@ with " + errorKind + "; should be " + constraint + parameterCount.toString() + ".", initMethod,
  initMethod.getQualifiedName()