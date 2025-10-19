/**
 * @name Wrong name for an argument in a call
 * @description Detects function calls that use keyword arguments with names
 *              that do not match any parameter of the called function.
 *              Such mismatches cause TypeError exceptions at runtime.
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

// 查询使用错误命名参数的函数调用
from Call functionCall, FunctionObject targetFunction, string argumentName
where
  // 检查调用中是否存在非法命名的参数
  illegally_named_parameter_objectapi(functionCall, targetFunction, argumentName) and
  // 确保目标函数是具体实现而非抽象定义
  not targetFunction.isAbstract() and
  // 排除参数名在父类重写方法中有效的情况
  not exists(FunctionObject overriddenMethod |
    targetFunction.overrides(overriddenMethod) and
    overriddenMethod.getFunction().getAnArg().(Name).getId() = argumentName
  )
select functionCall, 
  "Keyword argument '" + argumentName + "' is not a supported parameter name of $@.", 
  targetFunction, 
  targetFunction.descriptiveString()