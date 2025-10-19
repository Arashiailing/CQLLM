/**
 * @name Mismatch between signature and use of an overridden method
 * @description Detects methods whose signatures differ from both their overridden methods
 *              and the arguments used in their calls, potentially causing runtime errors.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python分析库，提供Python代码分析的基础功能
import Expressions.CallArgs  // 导入调用参数处理库，用于分析函数调用的参数

from Call methodCall, FunctionValue baseMethod, FunctionValue derivedMethod, string issueDescription  // 定义查询的数据源
where
  // 排除构造函数，因为它们的参数模式通常不同
  not baseMethod.getName() = "__init__" and
  
  // 确保派生类方法确实重写了基类方法
  derivedMethod.overrides(baseMethod) and
  
  // 获取派生类方法的调用节点
  methodCall = derivedMethod.getAMethodCall().getNode() and
  
  // 验证作为方法调用时参数是否正确
  correct_args_if_called_as_method(methodCall, derivedMethod) and
  
  // 检查各种参数不匹配情况
  (
    // 情况1：传递的参数数量少于基类方法所需的最小参数数量
    arg_count(methodCall) + 1 < baseMethod.minParameters() and 
    issueDescription = "too few arguments"
    
    or
    
    // 情况2：传递的参数数量超过基类方法所允许的最大参数数量
    arg_count(methodCall) >= baseMethod.maxParameters() and 
    issueDescription = "too many arguments"
    
    or
    
    // 情况3：存在派生类方法接受但基类方法不接受的关键字参数
    exists(string paramName |
      // 检查调用中的关键字参数名称
      methodCall.getAKeyword().getArg() = paramName and
      
      // 确认该参数名存在于派生类方法的参数列表中
      derivedMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // 确认该参数名不存在于基类方法的参数列表中
      not baseMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // 构建问题描述
      issueDescription = "an argument named '" + paramName + "'"
    )
  )
select baseMethod,  // 选择基类方法作为主要结果
  "Overridden method signature does not match $@, where it is passed " + issueDescription +
    ". Overriding method $@ matches the call.", methodCall, "call", derivedMethod,  // 生成描述性错误消息
  derivedMethod.descriptiveString()  // 提供派生类方法的详细描述