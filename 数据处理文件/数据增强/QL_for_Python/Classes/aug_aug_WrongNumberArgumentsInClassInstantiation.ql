/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与`__init__`方法定义不匹配的情况，这会导致运行时TypeError异常。
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

from Call callSite, ClassValue targetClass, string issueDescription, string requirementPrefix, int allowedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超过上限的情况
    too_many_args(callSite, targetClass, allowedArgCount) and
    issueDescription = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 处理参数数量低于下限的情况
    too_few_args(callSite, targetClass, allowedArgCount) and
    issueDescription = "too few arguments" and
    requirementPrefix = "no fewer than "
  )
select callSite, "Call to $@ with " + issueDescription + "; should be " + requirementPrefix + allowedArgCount.toString() + ".", classInitializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  classInitializer.getQualifiedName()