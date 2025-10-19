/**
 * @name 错误的类实例化参数数量
 * @description 检测类构造函数调用时参数数量不匹配的问题。
 *              当调用类的 `__init__` 方法时，传递过多或过少的参数
 *              将在运行时引发 TypeError 异常。
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

from Call invocation, ClassValue targetClass, string issueType, string constraintType, int paramLimit, FunctionValue initializer
where
  // 确定参数数量问题的类型（过多或过少）
  (
    // 检测参数过多的情况
    too_many_args(invocation, targetClass, paramLimit) and
    issueType = "too many arguments" and
    constraintType = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(invocation, targetClass, paramLimit) and
    issueType = "too few arguments" and
    constraintType = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initializer = get_function_or_initializer(targetClass)
select invocation, 
  "Call to $@ with " + issueType + "; should be " + constraintType + paramLimit.toString() + ".", 
  initializer,
  initializer.getQualifiedName()