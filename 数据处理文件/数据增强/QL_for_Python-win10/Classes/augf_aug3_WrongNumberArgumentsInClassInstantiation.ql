/**
 * @name 类构造函数参数数量不匹配
 * @description 检测类实例化时传递给`__init__`方法的参数数量与定义不符的情况，
 *              这种情况会导致运行时TypeError异常。
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

from Call callExpr, ClassValue classObj, string problemType, string constraint, int expectedArgCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（__init__或构造函数）
  initMethod = get_function_or_initializer(classObj) and
  (
    // 检测参数过多的情况
    too_many_args(callExpr, classObj, expectedArgCount) and
    problemType = "too many arguments" and
    constraint = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(callExpr, classObj, expectedArgCount) and
    problemType = "too few arguments" and
    constraint = "no fewer than "
  )
select callExpr, "Call to $@ with " + problemType + "; should be " + constraint + expectedArgCount.toString() + ".", initMethod,
  initMethod.getQualifiedName()