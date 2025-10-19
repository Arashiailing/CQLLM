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

from Call callNode, ClassValue instantiatedClass, 
     string errorMessage, string constraintMessage, 
     int expectedArgCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（构造函数）
  initMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 处理参数过多的情况
    too_many_args(callNode, instantiatedClass, expectedArgCount) and
    errorMessage = "too many arguments" and
    constraintMessage = "no more than "
    or
    // 处理参数过少的情况
    too_few_args(callNode, instantiatedClass, expectedArgCount) and
    errorMessage = "too few arguments" and
    constraintMessage = "no fewer than "
  )
select callNode, 
       "Call to $@ with " + errorMessage + "; should be " + constraintMessage + expectedArgCount.toString() + ".", 
       initMethod,
       // 输出调用点、错误消息及初始化方法的完全限定名
       initMethod.getQualifiedName()