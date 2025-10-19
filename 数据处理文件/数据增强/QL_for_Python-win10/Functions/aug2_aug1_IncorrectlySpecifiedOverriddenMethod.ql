/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects methods where the signature differs from both its overridden methods 
 *              and the actual call arguments, which may lead to runtime errors when invoked.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python代码分析库，用于执行Python代码的静态分析
import Expressions.CallArgs  // 导入调用参数处理库，用于处理函数调用参数的分析

from Call methodInvocation, FunctionValue parentMethod, FunctionValue childMethod, string problemDescription
where
  // 排除构造函数，仅分析普通方法
  not parentMethod.getName() = "__init__" and
  // 确认子类方法确实重写了父类方法
  childMethod.overrides(parentMethod) and
  // 获取子类方法的调用节点
  methodInvocation = childMethod.getAMethodCall().getNode() and
  // 验证作为方法调用时的参数正确性
  correct_args_if_called_as_method(methodInvocation, childMethod) and
  (
    // 检查参数数量不足的情况
    (
      arg_count(methodInvocation) + 1 < parentMethod.minParameters() and 
      problemDescription = "too few arguments"
    )
    or
    // 检查参数数量过多的情况
    (
      arg_count(methodInvocation) >= parentMethod.maxParameters() and 
      problemDescription = "too many arguments"
    )
    or
    // 检查关键字参数不匹配的情况
    (
      exists(string parameterName |
        // 获取调用中的关键字参数名称
        methodInvocation.getAKeyword().getArg() = parameterName and
        // 确认该参数名存在于子类方法中
        childMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 确认该参数名不存在于父类方法中
        not parentMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 构建问题描述
        problemDescription = "an argument named '" + parameterName + "'"
      )
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,
  childMethod.descriptiveString()