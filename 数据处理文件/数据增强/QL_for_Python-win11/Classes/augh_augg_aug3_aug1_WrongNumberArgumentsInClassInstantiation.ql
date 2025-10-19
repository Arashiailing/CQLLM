/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的问题。
 *              当调用类的 `__init__` 方法时，传入过多或过少的参数会导致运行时 TypeError 异常。
 *              此查询识别这些潜在的错误，帮助开发者在编码阶段就发现并修复这些问题。
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

from Call classCall, ClassValue instantiatedClass, string errorMessage, string constraintType, int requiredParamCount, FunctionValue classInitializer
where
  // 获取目标类的构造函数或初始化方法
  classInitializer = get_function_or_initializer(instantiatedClass) and
  (
    // 检测参数数量超过限制的情况
    too_many_args(classCall, instantiatedClass, requiredParamCount) and
    errorMessage = "too many arguments" and
    constraintType = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(classCall, instantiatedClass, requiredParamCount) and
    errorMessage = "too few arguments" and
    constraintType = "no fewer than "
  )
select classCall, "Call to $@ with " + errorMessage + "; should be " + constraintType + requiredParamCount.toString() + ".", classInitializer,
  classInitializer.getQualifiedName()