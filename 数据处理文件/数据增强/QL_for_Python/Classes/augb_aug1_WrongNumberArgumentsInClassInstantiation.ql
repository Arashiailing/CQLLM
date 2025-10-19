/**
 * @name 类实例化参数数量错误
 * @description 检测类实例化时参数数量不匹配的问题。当调用类的构造函数时，
 *              如果传入的参数数量与定义不符，会导致运行时 TypeError 异常。
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

from Call classCreationCall, ClassValue instantiatedClass, string errorMessage, string requirementDescription, int argumentLimit, FunctionValue classInitializer
where
  (
    // 检测参数过多的情况
    too_many_args(classCreationCall, instantiatedClass, argumentLimit) and
    errorMessage = "too many arguments" and
    requirementDescription = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(classCreationCall, instantiatedClass, argumentLimit) and
    errorMessage = "too few arguments" and
    requirementDescription = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  classInitializer = get_function_or_initializer(instantiatedClass)
select classCreationCall, "Call to $@ with " + errorMessage + "; should be " + requirementDescription + argumentLimit.toString() + ".", classInitializer,
  classInitializer.getQualifiedName()