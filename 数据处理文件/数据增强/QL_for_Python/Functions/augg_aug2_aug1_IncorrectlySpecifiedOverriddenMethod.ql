/**
 * @name Mismatch between signature and use of an overridden method
 * @description Identifies methods where the signature differs from both its overridden methods 
 *              and the actual call arguments, potentially causing runtime errors during invocation.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 引入Python代码分析库，支持Python代码的静态分析功能
import Expressions.CallArgs  // 引入调用参数处理库，用于分析函数调用参数

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription
where
  // 过滤掉构造函数，只关注普通方法
  not baseMethod.getName() = "__init__" and
  // 确保派生类方法确实覆盖了基类方法
  derivedMethod.overrides(baseMethod) and
  // 获取派生类方法的调用节点
  methodCall = derivedMethod.getAMethodCall().getNode() and
  // 验证作为方法调用时的参数是否正确
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  (
    // 情况1: 参数数量不足
    (
      arg_count(methodCall) + 1 < baseMethod.minParameters() and 
      issueDescription = "too few arguments"
    )
    or
    // 情况2: 参数数量过多
    (
      arg_count(methodCall) >= baseMethod.maxParameters() and 
      issueDescription = "too many arguments"
    )
    or
    // 情况3: 关键字参数不匹配
    (
      exists(string parameterName |
        // 提取调用中的关键字参数名称
        methodCall.getAKeyword().getArg() = parameterName and
        // 确认该参数名存在于派生类方法中
        derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 确认该参数名不存在于基类方法中
        not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 构建问题描述
        issueDescription = "an argument named '" + parameterName + "'"
      )
    )
  )
select baseMethod,
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,
  derivedMethod.descriptiveString()