/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与`__init__`方法定义不匹配的情况，
 *              这会导致运行时TypeError异常。
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

from Call callExpr, ClassValue targetCls, string issueDesc, string reqPrefix, int allowedCount, FunctionValue initMethod
where
  // 获取目标类的初始化方法（构造函数）
  initMethod = get_function_or_initializer(targetCls)
  and (
    // 处理参数数量超过上限的情况
    too_many_args(callExpr, targetCls, allowedCount)
    and issueDesc = "too many arguments"
    and reqPrefix = "no more than "
    or
    // 处理参数数量低于下限的情况
    too_few_args(callExpr, targetCls, allowedCount)
    and issueDesc = "too few arguments"
    and reqPrefix = "no fewer than "
  )
select callExpr, 
  "Call to $@ with " + issueDesc + "; should be " + reqPrefix + allowedCount.toString() + ".", 
  initMethod,
  // 输出调用点、错误消息及初始化方法的完全限定名
  initMethod.getQualifiedName()