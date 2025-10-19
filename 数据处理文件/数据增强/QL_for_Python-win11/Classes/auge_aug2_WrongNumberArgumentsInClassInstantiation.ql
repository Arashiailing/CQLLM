/**
 * @name 类实例化参数数量错误
 * @description 识别类构造函数调用时参数数量不匹配的情况。
 *              在调用类的 `__init__` 方法时，传入参数数量与期望不符
 *              会导致运行时抛出 TypeError 异常。
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

from Call methodCall, ClassValue targetCls, string argIssue, string limitType, int argCount, FunctionValue constructor
where
  // 获取目标类的构造函数或初始化方法
  constructor = get_function_or_initializer(targetCls) and
  // 确定参数数量问题的具体类型（过多或过少）
  (
    // 检测参数数量超过限制的情况
    too_many_args(methodCall, targetCls, argCount) and
    argIssue = "too many arguments" and
    limitType = "no more than "
    or
    // 检测参数数量不足的情况
    too_few_args(methodCall, targetCls, argCount) and
    argIssue = "too few arguments" and
    limitType = "no fewer than "
  )
select methodCall, 
  "Call to $@ with " + argIssue + "; should be " + limitType + argCount.toString() + ".", 
  constructor,
  constructor.getQualifiedName()