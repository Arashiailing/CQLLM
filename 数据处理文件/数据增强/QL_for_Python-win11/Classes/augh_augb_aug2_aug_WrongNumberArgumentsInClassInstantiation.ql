/**
 * @name 类实例化参数数量不匹配
 * @description 检测 Python 类实例化时传入 `__init__` 方法的参数数量不匹配问题。
 *              当实例化类时提供的参数数量与构造函数定义不匹配时，
 *              会导致运行时抛出 TypeError 异常。此查询识别两种情况：
 *              1. 提供的参数多于构造函数期望的参数
 *              2. 提供的参数少于构造函数期望的参数
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

from Call classInstantiation, ClassValue targetClass, 
     string errorMessageType, string countPrefix, 
     int expectedArgumentCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（构造函数）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 检查参数过多的情况
    too_many_args(classInstantiation, targetClass, expectedArgumentCount) and
    errorMessageType = "too many arguments" and
    countPrefix = "no more than "
    or
    // 检查参数过少的情况
    too_few_args(classInstantiation, targetClass, expectedArgumentCount) and
    errorMessageType = "too few arguments" and
    countPrefix = "no fewer than "
  )
select classInstantiation, 
       "Call to $@ with " + errorMessageType + "; should be " + countPrefix + expectedArgumentCount.toString() + ".", 
       classInitializer,
       // 输出调用点、错误消息及初始化方法的完全限定名
       classInitializer.getQualifiedName()