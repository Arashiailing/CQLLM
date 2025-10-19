/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化时传入 `__init__` 方法的参数数量错误，
 *              参数过多或过少均会导致运行时 TypeError 异常
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

from Call invocationNode, ClassValue targetClass, 
     string errorType, string constraintPrefix, 
     int requiredArgCount, FunctionValue constructorMethod
where
  // 获取目标类的初始化方法（构造函数）
  constructorMethod = get_function_or_initializer(targetClass) and
  (
    // 检查参数过多的情况
    too_many_args(invocationNode, targetClass, requiredArgCount) and
    errorType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 检查参数过少的情况
    too_few_args(invocationNode, targetClass, requiredArgCount) and
    errorType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocationNode, 
       "Call to $@ with " + errorType + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
       constructorMethod,
       // 输出调用点、错误消息及初始化方法的完全限定名
       constructorMethod.getQualifiedName()