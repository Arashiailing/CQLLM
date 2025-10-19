/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的问题。当调用类的构造函数时，
 *              如果传入的参数数量与`__init__`方法定义的参数数量不匹配，
 *              将会导致运行时TypeError异常。
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

from Call classCall, ClassValue invokedClass, string errorMessage, string constraintMessage, int requiredParamCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（__init__ 或构造函数）
  classInitializer = get_function_or_initializer(invokedClass) and
  (
    // 检测参数数量超过限制的情况
    too_many_args(classCall, invokedClass, requiredParamCount) and
    errorMessage = "too many arguments" and
    constraintMessage = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classCall, invokedClass, requiredParamCount) and
    errorMessage = "too few arguments" and
    constraintMessage = "no fewer than "
  )
select classCall, "Call to $@ with " + errorMessage + "; should be " + constraintMessage + requiredParamCount.toString() + ".", classInitializer,
  classInitializer.getQualifiedName()