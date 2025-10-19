/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化调用时传递的参数数量与构造函数（__init__方法）定义不匹配的情况。
 *              这种不匹配会导致运行时TypeError异常，影响代码的健壮性和可靠性。
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

from Call classInstantiation, ClassValue instantiatedClass, string errorType, string constraintDescription, int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（通常是__init__）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量超过上限的情况
    too_many_args(classInstantiation, instantiatedClass, expectedArgCount) and
    errorType = "too many arguments" and
    constraintDescription = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(classInstantiation, instantiatedClass, expectedArgCount) and
    errorType = "too few arguments" and
    constraintDescription = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + errorType + "; should be " + constraintDescription + expectedArgCount.toString() + ".", classInitializer,
  // 输出调用点、错误描述及初始化方法的完全限定名称
  classInitializer.getQualifiedName()