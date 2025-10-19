/**
 * @name Method Signature Mismatch in Overridden Methods
 * @description Detects methods in derived classes whose signatures differ from their base class counterparts,
 *              and identifies cases where actual method calls don't align with either signature,
 *              potentially leading to runtime invocation errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python代码分析库，支持Python代码的静态分析功能
import Expressions.CallArgs  // 导入调用参数处理库，用于分析函数调用参数

from Call invocationNode, FunctionValue parentMethod, FunctionValue childMethod, string mismatchReason
where
  // 排除构造函数，仅关注普通实例方法
  not parentMethod.getName() = "__init__" and
  // 确认子类方法确实覆盖了父类方法
  childMethod.overrides(parentMethod) and
  // 获取子类方法的调用节点
  invocationNode = childMethod.getAMethodCall().getNode() and
  // 验证作为方法调用时的参数是否正确
  correct_args_if_called_as_method(invocationNode, childMethod) and
  (
    // 检查参数数量不匹配的情况
    (
      arg_count(invocationNode) + 1 < parentMethod.minParameters() and 
      mismatchReason = "too few arguments"
    )
    or
    (
      arg_count(invocationNode) >= parentMethod.maxParameters() and 
      mismatchReason = "too many arguments"
    )
    or
    // 检查关键字参数不匹配的情况
    (
      exists(string parameterName |
        // 从调用中提取关键字参数名称
        invocationNode.getAKeyword().getArg() = parameterName and
        // 确认该参数名存在于子类方法中
        childMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 确认该参数名不存在于父类方法中
        not parentMethod.getScope().getAnArg().(Name).getId() = parameterName and
        // 构建问题描述
        mismatchReason = "an argument named '" + parameterName + "'"
      )
    )
  )
select parentMethod,
  "Overridden method signature does not match $@, where it is passed " + mismatchReason +
    ". Overriding method $@ matches the call.", invocationNode, "call", childMethod,
  childMethod.descriptiveString()