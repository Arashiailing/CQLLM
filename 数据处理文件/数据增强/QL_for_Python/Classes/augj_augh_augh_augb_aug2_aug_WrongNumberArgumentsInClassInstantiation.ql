/**
 * @name 类实例化参数数量不匹配
 * @description 识别 Python 类实例化过程中传递给 `__init__` 方法的参数数量与定义不符的情况。
 *              当创建类实例时提供的参数个数与构造函数签名不匹配时，
 *              将在运行时引发 TypeError 异常。本查询捕获两种典型场景：
 *              1. 实际参数数量超过构造函数期望的参数数量
 *              2. 实际参数数量少于构造函数期望的参数数量
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

from Call classInstanceCall, ClassValue targetClass, 
     string errorMessage, string errorPrefix, 
     int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（即构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  
  // 检查参数数量不匹配的两种情况
  (
    // 情况1：参数数量过多
    too_many_args(classInstanceCall, targetClass, expectedArgCount) and
    errorMessage = "too many arguments" and
    errorPrefix = "no more than "
  )
  or
  (
    // 情况2：参数数量过少
    too_few_args(classInstanceCall, targetClass, expectedArgCount) and
    errorMessage = "too few arguments" and
    errorPrefix = "no fewer than "
  )
select classInstanceCall, 
       "Call to $@ with " + errorMessage + "; should be " + errorPrefix + expectedArgCount.toString() + ".", 
       classInitializer,
       // 输出调用点、错误描述及初始化方法的完全限定名
       classInitializer.getQualifiedName()