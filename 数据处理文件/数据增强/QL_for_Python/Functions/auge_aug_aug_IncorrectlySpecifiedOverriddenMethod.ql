/**
 * @name 重写方法签名与使用不匹配
 * @description 检测方法重写时签名不匹配的情况，包括参数数量或名称不一致，
 *              这可能导致运行时错误或意外行为。
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python库，用于处理Python代码的查询
import Expressions.CallArgs  // 导入表达式调用参数库，用于处理函数调用参数

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription  // 从方法调用、基类方法、派生类方法和问题描述字符串中选择数据
where
  // 基本条件：确保存在有效的方法重写关系（排除构造函数）
  not baseMethod.getName() = "__init__" and  // 排除构造函数 '__init__'
  derivedMethod.overrides(baseMethod) and  // 确保 'derivedMethod' 是 'baseMethod' 的重写方法
  
  // 调用条件：获取重写方法的调用节点并验证参数
  methodCall = derivedMethod.getAMethodCall().getNode() and  // 获取重写方法的调用节点
  correct_args_if_called_as_method(methodCall, derivedMethod) and  // 检查如果作为方法调用时，参数是否正确
  
  // 参数不匹配条件
  (
    // 情况1：参数数量不匹配
    (
      // 参数数量少于基方法所需的最小参数数量
      arg_count(methodCall) + 1 < baseMethod.minParameters() and 
      issueDescription = "too few arguments"  // 标记为"参数过少"
      or
      // 参数数量超过基方法所允许的最大参数数量
      arg_count(methodCall) >= baseMethod.maxParameters() and 
      issueDescription = "too many arguments"  // 标记为"参数过多"
    )
    or
    // 情况2：参数名称不匹配
    exists(string parameterName |
      // 调用中使用了关键字参数
      methodCall.getAKeyword().getArg() = parameterName and  
      // 该参数存在于派生方法的参数列表中
      derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and  
      // 但该参数不存在于基方法的参数列表中
      not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and  
      issueDescription = "an argument named '" + parameterName + "'"  // 标记不匹配的参数名称
    )
  )
select baseMethod,  // 选择原始方法
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,  // 生成问题描述
  derivedMethod.descriptiveString()  // 提供重写方法的描述性字符串