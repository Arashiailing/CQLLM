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

from Call classCreation, ClassValue instantiatedClass, string errorDescription, string parameterConstraint, int parameterCount, FunctionValue initMethod
where
  (
    // 检测参数过多的情况
    too_many_args(classCreation, instantiatedClass, parameterCount) and
    errorDescription = "too many arguments" and
    parameterConstraint = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(classCreation, instantiatedClass, parameterCount) and
    errorDescription = "too few arguments" and
    parameterConstraint = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initMethod = get_function_or_initializer(instantiatedClass)
select classCreation, 
  "Call to $@ with " + errorDescription + "; should be " + parameterConstraint + parameterCount.toString() + ".", 
  initMethod,
  initMethod.getQualifiedName()