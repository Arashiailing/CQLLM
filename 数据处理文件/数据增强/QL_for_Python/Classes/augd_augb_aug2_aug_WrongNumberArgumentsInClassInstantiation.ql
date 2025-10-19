/**
 * @name 类实例化参数数量不匹配
 * @description 识别在类实例化过程中传递给构造函数 `__init__` 的参数数量不正确的情况。
 *              无论是参数过多还是参数不足，都会在运行时引发 TypeError 异常。
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

from Call classCall, ClassValue targetClass, 
     string errorMessage, string constraintPrefix, 
     int requiredArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（即构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 检测参数数量超过预期的情况
    too_many_args(classCall, targetClass, requiredArgCount) and
    errorMessage = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classCall, targetClass, requiredArgCount) and
    errorMessage = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select classCall, 
       "Call to $@ with " + errorMessage + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
       classInitializer,
       // 返回类调用点、错误描述以及初始化方法的完全限定名称
       classInitializer.getQualifiedName()