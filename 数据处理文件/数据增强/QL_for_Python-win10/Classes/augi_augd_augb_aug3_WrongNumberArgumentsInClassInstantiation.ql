/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时传递给 `__init__` 方法的参数数量与定义不符的情况，
 *              包括参数过多（超过定义数量）和参数过少（少于定义数量）两种情形，
 *              这些情况会导致运行时 TypeError 异常。
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

from Call instanceCreation, ClassValue targetClass, string issueType, string constraintDescription, int expectedArgCount, FunctionValue initializerMethod
where
  // 获取目标类的构造函数或初始化方法
  initializerMethod = get_function_or_initializer(targetClass)
  and (
    // 检测参数数量超过定义的情况
    too_many_args(instanceCreation, targetClass, expectedArgCount)
    and issueType = "too many arguments"
    and constraintDescription = "no more than "
    or
    // 检测参数数量少于定义的情况
    too_few_args(instanceCreation, targetClass, expectedArgCount)
    and issueType = "too few arguments"
    and constraintDescription = "no fewer than "
  )
select instanceCreation, "Call to $@ with " + issueType + "; should be " + constraintDescription + expectedArgCount.toString() + ".", initializerMethod,
  initializerMethod.getQualifiedName()