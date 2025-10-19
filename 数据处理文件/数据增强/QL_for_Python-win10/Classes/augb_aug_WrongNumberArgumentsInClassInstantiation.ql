/**
 * @name 错误的类实例化参数数量
 * @description 类的 `__init__` 方法调用时传入参数数量不匹配，会导致运行时 TypeError 异常。
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

from Call callSite, ClassValue targetClass, string argProblem, string requirementPrefix, int argCountLimit, FunctionValue initMethod
where
  // 获取目标类的初始化方法（__init__或构造函数）
  initMethod = get_function_or_initializer(targetClass) and
  (
    // 处理参数过多的情况
    too_many_args(callSite, targetClass, argCountLimit) and
    argProblem = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(callSite, targetClass, argCountLimit) and
    argProblem = "too few arguments" and
    requirementPrefix = "no fewer than "
  )
select callSite, "Call to $@ with " + argProblem + "; should be " + requirementPrefix + argCountLimit.toString() + ".", initMethod,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initMethod.getQualifiedName()