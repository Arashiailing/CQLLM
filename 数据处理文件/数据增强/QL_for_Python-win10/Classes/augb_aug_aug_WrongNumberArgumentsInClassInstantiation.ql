/**
 * @name 错误的类实例化参数数量
 * @description 检测类实例化时传入参数数量与`__init__`方法定义不匹配的情况，这会导致运行时TypeError异常。
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

from Call instantiationCall, ClassValue targetCls, string issueType, string qualifierText, int validArgCount, FunctionValue constructorMethod
where
  // 获取目标类的构造函数（__init__方法）
  constructorMethod = get_function_or_initializer(targetCls) and
  (
    // 处理参数数量超过构造函数允许上限的情况
    too_many_args(instantiationCall, targetCls, validArgCount) and
    issueType = "too many arguments" and
    qualifierText = "no more than "
    or
    // 处理参数数量低于构造函数要求下限的情况
    too_few_args(instantiationCall, targetCls, validArgCount) and
    issueType = "too few arguments" and
    qualifierText = "no fewer than "
  )
select instantiationCall, "Call to $@ with " + issueType + "; should be " + qualifierText + validArgCount.toString() + ".", constructorMethod,
  // 输出类实例化调用点、错误描述及构造函数的完全限定名
  constructorMethod.getQualifiedName()