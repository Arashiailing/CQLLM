/**
 * @name 重写方法签名与使用不匹配
 * @description 检测方法重写场景下，派生类方法签名与基类方法签名不一致，且调用时参数不匹配的情况，
 *              这种不匹配可能导致运行时错误或未定义行为。
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
  // 基础验证：排除构造函数并确保存在重写关系
  not baseMethod.getName() = "__init__" and  // 排除构造函数 '__init__'
  derivedMethod.overrides(baseMethod) and  // 确保 'derivedMethod' 是 'baseMethod' 的重写方法
  
  // 调用验证：获取派生类方法的调用节点并验证参数合法性
  methodCall = derivedMethod.getAMethodCall().getNode() and  // 获取派生类方法的调用节点
  correct_args_if_called_as_method(methodCall, derivedMethod) and  // 验证作为方法调用时参数是否正确
  
  // 参数不匹配检测：检查参数数量或名称的不一致
  (
    // 参数数量不匹配的情况
    (
      arg_count(methodCall) + 1 < baseMethod.minParameters() and issueDescription = "too few arguments"  // 当参数数量少于最小要求时标记为"参数过少"
      or
      arg_count(methodCall) >= baseMethod.maxParameters() and issueDescription = "too many arguments"  // 当参数数量超过最大限制时标记为"参数过多"
    )
    or
    // 参数名称不匹配的情况
    exists(string parameterName |
      methodCall.getAKeyword().getArg() = parameterName and  // 获取调用中的关键字参数名称
      derivedMethod.getScope().getAnArg().(Name).getId() = parameterName and  // 验证派生类方法中存在该参数
      not baseMethod.getScope().getAnArg().(Name).getId() = parameterName and  // 确认基类方法中不存在该参数
      issueDescription = "an argument named '" + parameterName + "'"  // 标记为"存在名为 'parameterName' 的参数"
    )
  )
select baseMethod,  // 选择基类方法作为主要输出
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,  // 生成问题描述，指出签名不匹配和参数问题
  derivedMethod.descriptiveString()  // 提供派生类方法的描述性字符串