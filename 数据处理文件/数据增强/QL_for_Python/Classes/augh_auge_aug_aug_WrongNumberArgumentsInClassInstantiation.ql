/**
 * @name 类实例化参数数量错误
 * @description 检测类实例化时提供的参数数量与构造函数(`__init__`方法)期望的参数数量不匹配的情况。
 *              这种不匹配会在运行时引发TypeError异常，影响程序可靠性。
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

from Call classInstantiation, ClassValue targetClass, string argMismatchType, string constraintDescription, int requiredArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  
  // 判断参数数量不匹配的类型并设置相应的描述
  (
    // 检测参数数量超过上限的情况
    too_many_args(classInstantiation, targetClass, requiredArgCount) and
    argMismatchType = "too many arguments" and
    constraintDescription = "no more than "
    or
    // 检测参数数量低于下限的情况
    too_few_args(classInstantiation, targetClass, requiredArgCount) and
    argMismatchType = "too few arguments" and
    constraintDescription = "no fewer than "
  )
select classInstantiation, 
  "Call to $@ with " + argMismatchType + "; should be " + constraintDescription + requiredArgCount.toString() + ".", 
  classInitializer,
  // 输出类实例化点、错误消息及构造方法的完全限定名
  classInitializer.getQualifiedName()