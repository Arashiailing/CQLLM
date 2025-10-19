/**
 * @name 错误的类实例化参数数量
 * @description 识别类实例化时传入参数数量与构造函数(__init__)定义不符的情况，这类错误会在运行时引发TypeError异常。
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

from Call classInstanceCall, ClassValue targetClass, string errorType, string constraintText, int expectedArgCount, FunctionValue classInitializer
where
  // 获取目标类的初始化方法（即__init__函数）
  classInitializer = get_function_or_initializer(targetClass) and
  (
    // 检测参数数量超过构造函数允许上限的情况
    too_many_args(classInstanceCall, targetClass, expectedArgCount) and
    errorType = "too many arguments" and
    constraintText = "no more than "
    or
    // 检测参数数量低于构造函数要求下限的情况
    too_few_args(classInstanceCall, targetClass, expectedArgCount) and
    errorType = "too few arguments" and
    constraintText = "no fewer than "
  )
select classInstanceCall, "Call to $@ with " + errorType + "; should be " + constraintText + expectedArgCount.toString() + ".", classInitializer,
  // 输出类实例化调用点、错误描述及构造函数的完全限定名
  classInitializer.getQualifiedName()