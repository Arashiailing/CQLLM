/**
 * @name 类实例化参数数量错误
 * @description 检测类实例化调用时传递的参数数量与类构造函数期望的参数数量不匹配的情况。
 *              这种不匹配可能导致运行时 TypeError 异常。
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

from Call classInstantiation, ClassValue instantiatedClass, string argumentIssueType, string argumentRequirementPrefix, int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（通常是__init__）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量是否过多
    too_many_args(classInstantiation, instantiatedClass, expectedArgCount) and
    argumentIssueType = "too many arguments" and
    argumentRequirementPrefix = "no more than "
    or
    // 检查参数数量是否过少
    too_few_args(classInstantiation, instantiatedClass, expectedArgCount) and
    argumentIssueType = "too few arguments" and
    argumentRequirementPrefix = "no fewer than "
  )
select classInstantiation, 
       "Call to $@ with " + argumentIssueType + "; should be " + argumentRequirementPrefix + expectedArgCount.toString() + ".", 
       classInitializer,
       classInitializer.getQualifiedName()