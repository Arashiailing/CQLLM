/**
 * @name 错误的类实例化参数数量
 * @description 检测类构造函数调用时参数数量不匹配的问题，当传递给类__init__方法的参数过多或过少时，
 *              将在运行时引发TypeError异常。
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

from Call invocation, ClassValue targetClass, string argIssue, string expected, int paramLimit, FunctionValue initializerMethod
where
  // 确定初始化方法
  initializerMethod = get_function_or_initializer(targetClass) and
  // 检查参数数量问题
  (
    // 处理参数过多的情况
    too_many_args(invocation, targetClass, paramLimit) and
    argIssue = "too many arguments" and
    expected = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(invocation, targetClass, paramLimit) and
    argIssue = "too few arguments" and
    expected = "no fewer than "
  )
select invocation, "Call to $@ with " + argIssue + "; should be " + expected + paramLimit.toString() + ".", initializerMethod,
  initializerMethod.getQualifiedName()