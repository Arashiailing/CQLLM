/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与类初始化方法（__init__）期望的参数数量不匹配的情况。
 *              当调用类构造函数时，如果传入的参数数量与类定义的 __init__ 方法参数数量不匹配，
 *              Python 解释器将在运行时抛出 TypeError 异常。此查询识别此类潜在错误，
 *              以提高代码的可靠性和正确性。
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

from Call classInstantiation, ClassValue instantiatedClass, string argumentIssue, string requirementQualifier, int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  (
    // 处理参数过多的情况
    too_many_args(classInstantiation, instantiatedClass, expectedArgCount) and
    argumentIssue = "too many arguments" and
    requirementQualifier = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(classInstantiation, instantiatedClass, expectedArgCount) and
    argumentIssue = "too few arguments" and
    requirementQualifier = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + argumentIssue + "; should be " + requirementQualifier + expectedArgCount.toString() + ".", classInitializer,
  // 输出调用点、错误消息及初始化方法的完全限定名
  classInitializer.getQualifiedName()