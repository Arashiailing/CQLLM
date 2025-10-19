/**
 * @name Wrong name for an argument in a call
 * @description Using a named argument whose name does not correspond to a
 *              parameter of the called function or method, will result in a
 *              TypeError at runtime.
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

// 查找使用非法命名参数的函数调用
from Call invocation, FunctionObject targetFunction, string argumentName
where
  // 检查调用中是否存在非法命名的参数
  illegally_named_parameter_objectapi(invocation, targetFunction, argumentName)
  and 
  // 确保目标函数不是抽象方法
  not targetFunction.isAbstract()
  and 
  // 排除重写函数中包含该参数名的情况
  not exists(FunctionObject overriddenFunction |
    // 检查目标函数是否重写了其他函数
    targetFunction.overrides(overriddenFunction)
    and 
    // 检查被重写函数是否包含该参数名
    overriddenFunction.getFunction().getAnArg().(Name).getId() = argumentName
  )
// 选择违规调用、错误描述信息及目标函数
select invocation, 
  "Keyword argument '" + argumentName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()