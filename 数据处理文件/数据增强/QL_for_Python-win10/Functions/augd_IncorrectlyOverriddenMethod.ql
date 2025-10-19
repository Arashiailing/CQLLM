/**
 * @name Mismatch between signature and use of an overriding method
 * @description Detects when an overriding method has a different signature from the overridden method,
 *              which would likely cause an error if called.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python  // 导入Python库，用于分析Python代码
import Expressions.CallArgs  // 导入表达式调用参数模块

// 定义查询语句，查找方法签名不匹配的问题
from Call methodCall, FunctionValue overridingMethod, FunctionValue baseMethod, string issueDescription
where
  // 检查overridingMethod是否重写了baseMethod
  overridingMethod.overrides(baseMethod) and  
  (
    // 情况1：调用时参数错误，但如果作为父类方法调用时参数正确
    wrong_args(methodCall, overridingMethod, _, issueDescription) and  
    correct_args_if_called_as_method(methodCall, baseMethod)  
    or
    // 情况2：存在非法命名的参数
    exists(string paramName |  
      illegally_named_parameter(methodCall, overridingMethod, paramName) and  
      issueDescription = "an argument named '" + paramName + "'" and  
      // 检查被重写的方法中是否有相同名称的参数
      baseMethod.getScope().getAnArg().(Name).getId() = paramName  
    )
  )
// 选择重写的方法并构建错误消息
select overridingMethod,  
  "Overriding method signature does not match $@, where it is passed " + issueDescription +
    ". Overridden method $@ is correctly specified.", methodCall, "here", baseMethod,
  baseMethod.descriptiveString()  // 输出问题描述和相关方法信息