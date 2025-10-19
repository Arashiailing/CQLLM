/**
 * @name 类实例化参数数量错误
 * @description 检测Python代码中类实例化调用时传递的参数数量与构造函数(`__init__`方法)
 *              定义的参数数量不匹配的情况。这种不匹配会导致运行时抛出TypeError异常，
 *              影响程序的正确性和可靠性。
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

from Call callSite, ClassValue targetClass, string errorDescription, string constraintText, int requiredArgCount, FunctionValue initializer
where
  // 获取目标类的构造函数(__init__方法)
  initializer = get_function_or_initializer(targetClass) and
  // 根据参数数量错误类型设置相应的错误描述和约束文本
  (
    // 检测参数数量超过构造函数接受上限的情况
    too_many_args(callSite, targetClass, requiredArgCount) and
    errorDescription = "too many arguments" and
    constraintText = "no more than "
    or
    // 检测参数数量低于构造函数要求下限的情况
    too_few_args(callSite, targetClass, requiredArgCount) and
    errorDescription = "too few arguments" and
    constraintText = "no fewer than "
  )
select callSite, "Call to $@ with " + errorDescription + "; should be " + constraintText + requiredArgCount.toString() + ".", initializer,
  // 输出调用点位置、错误消息以及构造方法的完全限定名
  initializer.getQualifiedName()