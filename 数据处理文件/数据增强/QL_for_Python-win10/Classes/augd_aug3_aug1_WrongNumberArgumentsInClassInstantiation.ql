/**
 * @name 类实例化参数数量不匹配
 * @description 识别类实例化过程中参数数量错误的情况。当调用类的构造函数或初始化方法时，
 *              提供的参数数量与方法定义不匹配，会导致运行时 TypeError 异常。
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

from Call classInstantiation, ClassValue targetClass, string errorType, string limitDescription, int expectedParamCount, FunctionValue initializer
where
  // 获取目标类的初始化方法
  initializer = get_function_or_initializer(targetClass) and
  (
    // 检查参数数量超过限制的情况
    too_many_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too many arguments" and
    limitDescription = "no more than "
    or
    // 检查参数数量不足的情况
    too_few_args(classInstantiation, targetClass, expectedParamCount) and
    errorType = "too few arguments" and
    limitDescription = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + errorType + "; should be " + limitDescription + expectedParamCount.toString() + ".", initializer,
  initializer.getQualifiedName()