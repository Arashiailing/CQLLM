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

from Call instanceCall, ClassValue targetClass, string errorDescription, string constraintDescription, int expectedCount, FunctionValue constructor
where
  // 获取目标类的构造函数（通常是__init__方法）
  constructor = get_function_or_initializer(targetClass) and
  (
    // 检查参数数量超过上限的情况
    too_many_args(instanceCall, targetClass, expectedCount) and
    errorDescription = "too many arguments" and
    constraintDescription = "no more than "
    or
    // 检查参数数量低于下限的情况
    too_few_args(instanceCall, targetClass, expectedCount) and
    errorDescription = "too few arguments" and
    constraintDescription = "no fewer than "
  )
select instanceCall, 
  "Call to $@ with " + errorDescription + "; should be " + constraintDescription + expectedCount.toString() + ".", 
  constructor,
  // 输出调用点、错误消息及构造函数的完全限定名
  constructor.getQualifiedName()