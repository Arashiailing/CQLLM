/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化时传入构造函数的参数数量错误，
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

from Call invocationExpr, ClassValue instantiatedClass, 
     string errorDescription, string constraintPrefix, 
     int requiredArgCount, FunctionValue constructorMethod
where
  // 获取目标类的构造方法（__init__函数）
  constructorMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 处理参数数量超过预期的情况
    too_many_args(invocationExpr, instantiatedClass, requiredArgCount) and
    errorDescription = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(invocationExpr, instantiatedClass, requiredArgCount) and
    errorDescription = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocationExpr, 
       "Call to $@ with " + errorDescription + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
       constructorMethod,
       // 输出调用点、错误消息及构造方法的完全限定名
       constructorMethod.getQualifiedName()