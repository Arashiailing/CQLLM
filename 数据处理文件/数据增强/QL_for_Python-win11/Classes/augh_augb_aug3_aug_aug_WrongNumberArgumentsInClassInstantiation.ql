/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与构造函数（__init__方法）定义不匹配的情况。
 *              当实例化类时传递的参数数量不符合构造函数的要求，程序会在运行时抛出TypeError异常。
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

from Call classInstantiation, ClassValue instantiatedClass, string errorType, string constraintType, int expectedArgCount, FunctionValue classConstructor
where
  // 获取目标类的构造函数（通常是__init__方法）
  classConstructor = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量不匹配的情况
    (
      // 参数数量超过上限
      too_many_args(classInstantiation, instantiatedClass, expectedArgCount) and
      errorType = "too many arguments" and
      constraintType = "no more than "
    )
    or
    (
      // 参数数量低于下限
      too_few_args(classInstantiation, instantiatedClass, expectedArgCount) and
      errorType = "too few arguments" and
      constraintType = "no fewer than "
    )
  )
select classInstantiation, "Call to $@ with " + errorType + "; should be " + constraintType + expectedArgCount.toString() + ".", classConstructor,
  // 输出调用点、错误消息及构造函数的完全限定名
  classConstructor.getQualifiedName()