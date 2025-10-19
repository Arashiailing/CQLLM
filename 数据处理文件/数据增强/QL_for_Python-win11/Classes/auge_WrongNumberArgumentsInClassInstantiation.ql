/**
 * @name 错误的类实例化参数数量
 * @description 在调用类的 `__init__` 方法时，使用过多或过少的参数将导致运行时出现 TypeError。
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

from Call invocation, ClassValue classObj, string errorMsg, string requirementPrefix, int paramLimit, FunctionValue initializer
where
  (
    // 检测参数数量超过限制的情况
    too_many_args(invocation, classObj, paramLimit) and
    errorMsg = "too many arguments" and
    requirementPrefix = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(invocation, classObj, paramLimit) and
    errorMsg = "too few arguments" and
    requirementPrefix = "no fewer than "
  ) and
  // 获取目标类的构造函数或初始化方法
  initializer = get_function_or_initializer(classObj)
select invocation, "Call to $@ with " + errorMsg + "; should be " + requirementPrefix + paramLimit.toString() + ".", initializer,
  // 返回调用节点、错误描述以及初始化方法的完整名称
  initializer.getQualifiedName()