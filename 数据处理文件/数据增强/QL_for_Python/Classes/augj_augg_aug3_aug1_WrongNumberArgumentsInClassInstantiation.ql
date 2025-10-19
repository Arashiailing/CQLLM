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

from Call instanceCall, ClassValue instantiatedClass, string errorMessage, string constraintMsg, int requiredParamCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  
  // 检查参数数量不匹配的情况
  (
    // 情况1：参数数量超过限制
    too_many_args(instanceCall, instantiatedClass, requiredParamCount) and
    errorMessage = "too many arguments" and
    constraintMsg = "no more than "
    or
    // 情况2：参数数量不足
    too_few_args(instanceCall, instantiatedClass, requiredParamCount) and
    errorMessage = "too few arguments" and
    constraintMsg = "no fewer than "
  )
select instanceCall, "Call to $@ with " + errorMessage + "; should be " + constraintMsg + requiredParamCount.toString() + ".", classInitializer,
  classInitializer.getQualifiedName()