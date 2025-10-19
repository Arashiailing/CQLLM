/**
 * @name 错误的类实例化参数数量
 * @description 检测类构造函数调用时参数数量不匹配的情况，会导致运行时 TypeError 异常。
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

from Call invocationPoint, ClassValue targetClass, string issueType, string constraintPrefix, int limit, FunctionValue initializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  initializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超限的情况
    too_many_args(invocationPoint, targetClass, limit) and
    issueType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(invocationPoint, targetClass, limit) and
    issueType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocationPoint, 
  "Call to $@ with " + issueType + "; should be " + constraintPrefix + limit.toString() + ".", 
  initializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initializer.getQualifiedName()