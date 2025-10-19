/**
 * @name Mismatch between signature and use of an overriding method
 * @description Detects methods that override a base method but with a different signature,
 *              which would likely cause errors if called.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python
import Expressions.CallArgs

// 查找方法签名不匹配的重写方法
from Call methodCall, FunctionValue overridingMethod, FunctionValue baseMethod, string issueDescription
where
  // 确保overridingMethod确实重写了baseMethod
  overridingMethod.overrides(baseMethod) and
  (
    // 情况1：调用overridingMethod时参数错误，但调用baseMethod时参数正确
    wrong_args(methodCall, overridingMethod, _, issueDescription) and
    correct_args_if_called_as_method(methodCall, baseMethod)
    or
    // 情况2：存在非法命名的参数
    exists(string paramName |
      illegally_named_parameter(methodCall, overridingMethod, paramName) and
      issueDescription = "an argument named '" + paramName + "'" and
      // 检查baseMethod中是否有相同名称的参数
      baseMethod.getScope().getAnArg().(Name).getId() = paramName
    )
  )
select overridingMethod,
  "Overriding method signature does not match $@, where it is passed " + issueDescription +
    ". Overridden method $@ is correctly specified.", methodCall, "here", baseMethod,
  baseMethod.descriptiveString()