/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与`__init__`方法定义不匹配的情况，
 *              这会导致运行时TypeError异常。
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

from Call classInstantiation, ClassValue targetClass, string argumentIssueType, string constraintQualifier, int expectedArgCount, FunctionValue classConstructor
where
  // 获取目标类的构造函数（__init__方法）
  classConstructor = get_function_or_initializer(targetClass)
  and
  (
    // 检查参数数量是否超过构造函数允许的上限
    too_many_args(classInstantiation, targetClass, expectedArgCount)
    and argumentIssueType = "too many arguments"
    and constraintQualifier = "no more than "
    or
    // 检查参数数量是否低于构造函数要求的下限
    too_few_args(classInstantiation, targetClass, expectedArgCount)
    and argumentIssueType = "too few arguments"
    and constraintQualifier = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + argumentIssueType + "; should be " + constraintQualifier + expectedArgCount.toString() + ".", classConstructor,
  // 输出类实例化调用点、错误描述及构造函数的完全限定名
  classConstructor.getQualifiedName()