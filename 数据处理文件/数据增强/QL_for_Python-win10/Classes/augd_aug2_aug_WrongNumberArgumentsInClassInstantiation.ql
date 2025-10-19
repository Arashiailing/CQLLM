/**
 * @name 类实例化参数数量不匹配
 * @description 此查询识别在实例化类时传递给构造函数的参数数量不正确的情况。
 *              当调用类构造函数时，如果提供的参数数量与 `__init__` 方法定义的参数数量不匹配，
 *              将在运行时引发 TypeError 异常。此查询检测参数过多或过少的情况。
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

from Call invocationExpr, ClassValue classToInstantiate, 
     string argumentMismatchType, string constraintPrefix, 
     int requiredArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（构造函数）
  classInitializer = get_function_or_initializer(classToInstantiate) and
  (
    // 处理参数数量超过预期的情况
    too_many_args(invocationExpr, classToInstantiate, requiredArgCount) and
    argumentMismatchType = "too many arguments" and
    constraintPrefix = "no more than "
    or
    // 处理参数数量不足的情况
    too_few_args(invocationExpr, classToInstantiate, requiredArgCount) and
    argumentMismatchType = "too few arguments" and
    constraintPrefix = "no fewer than "
  )
select invocationExpr, 
       "Call to $@ with " + argumentMismatchType + "; should be " + constraintPrefix + requiredArgCount.toString() + ".", 
       classInitializer,
       // 输出调用点、错误消息及初始化方法的完全限定名
       classInitializer.getQualifiedName()