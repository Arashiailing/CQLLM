/**
 * @name 重写方法签名与调用参数不匹配
 * @description 识别方法签名与其重写方法签名不一致的情况，
 *              以及调用参数不匹配问题，这类问题可能导致运行时错误。
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python库，用于分析Python代码结构
import Expressions.CallArgs  // 导入表达式调用参数库，用于处理函数调用参数分析

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string errorMsg  // 从方法调用、基类方法、派生类方法和错误消息字符串中选择数据
where
  // 基本条件：过滤构造函数并确认重写关系
  not baseMethod.getName() = "__init__" and  // 排除构造函数 '__init__'
  derivedMethod.overrides(baseMethod) and  // 确保 'derivedMethod' 是 'baseMethod' 的重写方法
  
  // 调用条件：获取重写方法的调用节点并验证参数正确性
  methodCall = derivedMethod.getAMethodCall().getNode() and  // 获取重写方法的调用节点
  correct_args_if_called_as_method(methodCall, derivedMethod) and  // 检查作为方法调用时参数是否正确
  
  // 参数不匹配条件：检测参数数量或名称不匹配
  (
    // 参数数量不匹配情况
    (
      arg_count(methodCall) + 1 < baseMethod.minParameters() and errorMsg = "too few arguments"  // 如果参数数量少于最小参数数量，标记为"参数过少"
      or
      arg_count(methodCall) >= baseMethod.maxParameters() and errorMsg = "too many arguments"  // 如果参数数量多于最大参数数量，标记为"参数过多"
    )
    or
    // 参数名称不匹配情况
    exists(string argName |
      methodCall.getAKeyword().getArg() = argName and  // 检查调用中的关键字参数名称
      derivedMethod.getScope().getAnArg().(Name).getId() = argName and  // 检查重写方法中的参数名称
      not baseMethod.getScope().getAnArg().(Name).getId() = argName and  // 检查基类方法中是否没有该参数名称
      errorMsg = "an argument named '" + argName + "'"  // 标记为"存在一个名为 'argName' 的参数"
    )
  )
select baseMethod,  // 选择基类方法
  "Overridden method signature does not match $@, where it is passed " + errorMsg +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,  // 生成错误消息，指出签名不匹配和传递的问题
  derivedMethod.descriptiveString()  // 提供重写方法的描述性字符串