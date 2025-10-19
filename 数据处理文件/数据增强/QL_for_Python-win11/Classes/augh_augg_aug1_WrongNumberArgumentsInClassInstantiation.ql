/**
 * @name 类实例化参数数量不匹配
 * @description 识别在类实例化过程中传递给构造函数的参数数量与预期不符的情况。
 *              当调用类的初始化方法 `__init__` 时，如果提供的参数数量不正确，
 *              将会在运行时引发 TypeError 异常。
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

from Call classInstantiation, ClassValue targetClass, string errorMsg, string paramConstraint, int expectedParamCount, FunctionValue initializerMethod
where
  (
    // 检测参数数量超过预期的情况
    too_many_args(classInstantiation, targetClass, expectedParamCount) and
    errorMsg = "too many arguments" and
    paramConstraint = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classInstantiation, targetClass, expectedParamCount) and
    errorMsg = "too few arguments" and
    paramConstraint = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initializerMethod = get_function_or_initializer(targetClass)
select classInstantiation, 
  "Call to $@ with " + errorMsg + "; should be " + paramConstraint + expectedParamCount.toString() + ".", 
  initializerMethod,
  initializerMethod.getQualifiedName()