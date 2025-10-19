/**
 * @name 类实例化参数数量不匹配
 * @description 识别类实例化调用中参数数量与构造函数（__init__方法）要求不符的情况。
 *              此类错误会在程序执行时引发TypeError异常，降低代码的健壮性。
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

from Call instanceCreation, ClassValue targetClass, string errorMessage, string constraintText, int requiredArgCount, FunctionValue initializerMethod
where
  // 获取目标类的初始化方法（通常是__init__）
  initializerMethod = get_function_or_initializer(targetClass) and
  (
    // 检查参数数量超过上限的情况
    too_many_args(instanceCreation, targetClass, requiredArgCount) and
    errorMessage = "too many arguments" and
    constraintText = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(instanceCreation, targetClass, requiredArgCount) and
    errorMessage = "too few arguments" and
    constraintText = "no fewer than "
  )
select instanceCreation, "Call to $@ with " + errorMessage + "; should be " + constraintText + requiredArgCount.toString() + ".", initializerMethod,
  // 输出调用点、错误描述及初始化方法的完全限定名称
  initializerMethod.getQualifiedName()