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

from Call classInvocation, 
     ClassValue targetClassType, 
     string issueDescription, 
     string constraintDescription, 
     int expectedParamCount, 
     FunctionValue classInitializer
where
  // 获取目标类的构造函数或初始化方法
  classInitializer = get_function_or_initializer(targetClassType) and
  // 确定参数数量问题的类型（过多或过少）
  (
    // 检测参数过多的情况
    too_many_args(classInvocation, targetClassType, expectedParamCount) and
    issueDescription = "too many arguments" and
    constraintDescription = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(classInvocation, targetClassType, expectedParamCount) and
    issueDescription = "too few arguments" and
    constraintDescription = "no fewer than "
  )
select classInvocation, 
  "Call to $@ with " + issueDescription + "; should be " + constraintDescription + expectedParamCount.toString() + ".", 
  classInitializer,
  classInitializer.getQualifiedName()