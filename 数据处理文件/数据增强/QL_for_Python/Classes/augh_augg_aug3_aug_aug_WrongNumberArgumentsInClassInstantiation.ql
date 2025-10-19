/**
 * @name 类实例化参数数量不匹配
 * @description 检测类实例化调用时传递的参数数量与构造函数(__init__方法)要求不符的情况。
 *              此类错误会导致运行时TypeError异常，降低代码健壮性。
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

from Call classInstantiation, ClassValue targetClass, string errorDescription, string constraintText, int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法(__init__)
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 处理参数数量超过上限的情况
    too_many_args(classInstantiation, targetClass, expectedArgCount) and
    errorDescription = "too many arguments" and
    constraintText = "no more than "
    or
    // 处理参数数量低于下限的情况
    too_few_args(classInstantiation, targetClass, expectedArgCount) and
    errorDescription = "too few arguments" and
    constraintText = "no fewer than "
  )
select classInstantiation, "Call to $@ with " + errorDescription + "; should be " + constraintText + expectedArgCount.toString() + ".", classInitializer,
  // 输出调用位置、错误描述及初始化方法的完全限定名称
  classInitializer.getQualifiedName()