/**
 * @name 错误的类实例化参数数量
 * @description 在调用类的 `__init__` 方法时，使用过多或过少的参数将导致运行时出现 TypeError。
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

from Call classCall, ClassValue targetClass, string errorDescription, string requirement, int parameterLimit, FunctionValue initializer
where
  (
    // 检测参数数量超过上限的情况
    too_many_args(classCall, targetClass, parameterLimit) and
    errorDescription = "too many arguments" and
    requirement = "no more than "
    or
    // 检测参数数量低于下限的情况
    too_few_args(classCall, targetClass, parameterLimit) and
    errorDescription = "too few arguments" and
    requirement = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initializer = get_function_or_initializer(targetClass)
select classCall, "Call to $@ with " + errorDescription + "; should be " + requirement + parameterLimit.toString() + ".", initializer,
  // 输出类调用对象、错误消息和初始化方法的完整限定名
  initializer.getQualifiedName()