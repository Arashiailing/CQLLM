/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化调用中传递的参数数量与类构造函数(__init__)定义不匹配的情况，
 *              这种不匹配会导致程序在运行时抛出TypeError异常。
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

from Call classCreationCall, ClassValue targetClass, string errorDescription, string constraintPrefix, int requiredArgCount, FunctionValue classConstructor
where
  // 获取目标类的构造函数（即__init__方法）
  classConstructor = get_function_or_initializer(targetClass)
  and (
    // 处理参数数量超过构造函数定义上限的情况
    too_many_args(classCreationCall, targetClass, requiredArgCount)
    and errorDescription = "too many arguments"
    and constraintPrefix = "no more than "
    or
    // 处理参数数量低于构造函数定义下限的情况
    too_few_args(classCreationCall, targetClass, requiredArgCount)
    and errorDescription = "too few arguments"
    and constraintPrefix = "no fewer than "
  )
select classCreationCall, 
  "Call to $@ with " + errorDescription + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
  classConstructor,
  // 输出调用点、错误消息及构造函数的完全限定名
  classConstructor.getQualifiedName()