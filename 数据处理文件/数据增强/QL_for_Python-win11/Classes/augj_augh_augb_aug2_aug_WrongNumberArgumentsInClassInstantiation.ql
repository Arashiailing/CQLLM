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

from Call classCreationCall, ClassValue instantiatedClass, 
     string errorDescription, string limitPrefix, 
     int requiredArgCount, FunctionValue constructorMethod
where
  // 获取目标类的初始化方法（构造函数）
  constructorMethod = get_function_or_initializer(instantiatedClass) and
  (
    // 检查参数过多的情况
    too_many_args(classCreationCall, instantiatedClass, requiredArgCount) and
    errorDescription = "too many arguments" and
    limitPrefix = "no more than "
    or
    // 检查参数过少的情况
    too_few_args(classCreationCall, instantiatedClass, requiredArgCount) and
    errorDescription = "too few arguments" and
    limitPrefix = "no fewer than "
  )
select classCreationCall, 
       "Call to $@ with " + errorDescription + "; should be " + limitPrefix + requiredArgCount.toString() + ".", 
       constructorMethod,
       // 输出调用点、错误消息及初始化方法的完全限定名
       constructorMethod.getQualifiedName()