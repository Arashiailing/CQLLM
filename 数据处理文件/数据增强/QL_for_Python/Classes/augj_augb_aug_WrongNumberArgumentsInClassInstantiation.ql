/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与 `__init__` 方法定义不匹配的情况，
 *              这种不匹配会在运行时导致 TypeError 异常。
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

from Call classInstantiation, 
     ClassValue instantiatedClass, 
     string argumentIssue, 
     string limitDescriptionPrefix, 
     int argumentCountLimit, 
     FunctionValue classInitializer
where
  // 获取目标类的初始化方法（__init__或构造函数）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数数量是否过多
    too_many_args(classInstantiation, instantiatedClass, argumentCountLimit) and
    argumentIssue = "too many arguments" and
    limitDescriptionPrefix = "no more than "
    or
    // 检查参数数量是否过少
    too_few_args(classInstantiation, instantiatedClass, argumentCountLimit) and
    argumentIssue = "too few arguments" and
    limitDescriptionPrefix = "no fewer than "
  )
select classInstantiation, 
       "Call to $@ with " + argumentIssue + "; should be " + limitDescriptionPrefix + argumentCountLimit.toString() + ".", 
       classInitializer,
       // 输出调用点、错误消息及初始化方法的完全限定名
       classInitializer.getQualifiedName()