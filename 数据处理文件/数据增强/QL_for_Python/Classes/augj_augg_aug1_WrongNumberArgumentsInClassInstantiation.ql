/**
 * @name 错误的类实例化参数数量
 * @description 识别在类实例化过程中参数数量不匹配的情况。当调用类的构造函数或
 *              `__init__` 方法时，如果提供的参数数量与定义不符，将导致运行时
 *              TypeError 异常，影响程序的可靠性。
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

from Call classInstanceCall, ClassValue targetClass, string errorType, string constraintDescription, int expectedParamCount, FunctionValue classInitializer
where
  (
    // 检测参数数量不匹配的情况
    (
      // 参数过多的情况
      too_many_args(classInstanceCall, targetClass, expectedParamCount) and
      errorType = "too many arguments" and
      constraintDescription = "no more than "
    )
    or
    (
      // 参数过少的情况
      too_few_args(classInstanceCall, targetClass, expectedParamCount) and
      errorType = "too few arguments" and
      constraintDescription = "no fewer than "
    )
  ) and
  // 获取目标类的构造函数或初始化方法
  classInitializer = get_function_or_initializer(targetClass)
select classInstanceCall, 
  "Call to $@ with " + errorType + "; should be " + constraintDescription + expectedParamCount.toString() + ".", 
  classInitializer,
  classInitializer.getQualifiedName()