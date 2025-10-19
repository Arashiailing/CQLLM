/**
 * @name Wrong name for an argument in a call
 * @description Detects calls using named arguments that don't match any parameter
 *              of the target function/method, causing runtime TypeErrors.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-argument
 */

import python
import Expressions.CallArgs

// 查找使用了无效命名参数的函数调用
from Call funcInvocation, FunctionObject targetFunction, string invalidArgName
where
  // 核心检测：参数名与目标函数的任何参数都不匹配
  illegally_named_parameter_objectapi(funcInvocation, targetFunction, invalidArgName) and
  // 排除抽象函数（它们可能具有动态参数）
  not targetFunction.isAbstract() and
  // 排除参数在父类方法中已定义的情况
  not exists(FunctionObject baseMethod |
    targetFunction.overrides(baseMethod) and
    baseMethod.getFunction().getAnArg().(Name).getId() = invalidArgName
  )
select funcInvocation, 
  "Keyword argument '" + invalidArgName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()