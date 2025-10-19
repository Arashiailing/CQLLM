/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时参数数量不匹配的情况。当调用类的构造函数（通常是`__init__`方法）时，
 *              传入过多或过少的参数会导致运行时TypeError异常。
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

from Call instanceCall, ClassValue targetCls, string errType, string reqMsg, int limit, FunctionValue initMethod
where
  (
    // 检测参数过多的情况
    too_many_args(instanceCall, targetCls, limit) and
    errType = "too many arguments" and
    reqMsg = "no more than "
    or
    // 检测参数过少的情况
    too_few_args(instanceCall, targetCls, limit) and
    errType = "too few arguments" and
    reqMsg = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initMethod = get_function_or_initializer(targetCls)
select instanceCall, "Call to $@ with " + errType + "; should be " + reqMsg + limit.toString() + ".", initMethod,
  initMethod.getQualifiedName()