/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化调用时参数数量不匹配的情况，可能导致运行时 TypeError 异常。
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

from Call callNode, ClassValue targetClass, string issueType, string requirementPrefix, int requiredArgCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法
  initMethod = get_function_or_initializer(targetClass) and
  (
    // 处理参数过多的情况
    too_many_args(callNode, targetClass, requiredArgCount) and
    issueType = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(callNode, targetClass, requiredArgCount) and
    issueType = "too few arguments" and
    requirementPrefix = "no fewer than "
  )
select callNode, "Call to $@ with " + issueType + "; should be " + requirementPrefix + requiredArgCount.toString() + ".", initMethod,
  // 输出调用点、错误描述及初始化方法的完全限定名
  initMethod.getQualifiedName()