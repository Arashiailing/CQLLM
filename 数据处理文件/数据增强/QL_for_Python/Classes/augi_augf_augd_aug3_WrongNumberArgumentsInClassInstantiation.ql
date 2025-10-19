/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时提供给 `__init__` 方法的参数数量与定义不符的情况，
 *              这种情况会导致运行时 TypeError 异常。
 * 
 *              此查询识别以下两种情况：
 *              1. 提供给构造函数的参数数量多于定义的参数数量
 *              2. 提供给构造函数的参数数量少于定义的参数数量
 * 
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

from Call classCreationCall, ClassValue instantiatedClass, string errorDescription, string constraintDescription, int requiredArgumentCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（构造函数）
  classInitializer = get_function_or_initializer(instantiatedClass) and
  // 检查参数数量不匹配的情况
  (
    // 处理参数数量过多的情况
    too_many_args(classCreationCall, instantiatedClass, requiredArgumentCount) and
    errorDescription = "too many arguments" and
    constraintDescription = "no more than "
    or
    // 处理参数数量过少的情况
    too_few_args(classCreationCall, instantiatedClass, requiredArgumentCount) and
    errorDescription = "too few arguments" and
    constraintDescription = "no fewer than "
  )
select classCreationCall, 
  "Call to $@ with " + errorDescription + "; should be " + constraintDescription + requiredArgumentCount.toString() + ".", 
  classInitializer,
  classInitializer.getQualifiedName()