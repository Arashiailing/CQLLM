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

from Call methodInvocation, FunctionValue parentMethod, FunctionValue childMethod, string errorDescription  // 定义查询的数据源
where
  // 排除构造函数，因为它们的参数模式通常不同
  not parentMethod.getName() = "__init__" and
  
  // 确保子类方法确实重写了父类方法
  childMethod.overrides(parentMethod) and
  
  // 获取子类方法的调用节点
  methodInvocation = childMethod.getAMethodCall().getNode() and
  
  // 验证作为方法调用时参数是否正确
  correct_args_if_called_as_method(methodInvocation, childMethod) and
  
  // 检查各种参数不匹配情况
  (
    // 情况1：传递的参数数量少于父类方法所需的最小参数数量
    arg_count(methodInvocation) + 1 < parentMethod.minParameters() and 
    errorDescription = "too few arguments"
    
    or
    
    // 情况2：传递的参数数量超过父类方法所允许的最大参数数量
    arg_count(methodInvocation) >= parentMethod.maxParameters() and 
    errorDescription = "too many arguments"
    
    or
    
    // 情况3：存在子类方法接受但父类方法不接受的关键字参数
    exists(string parameterName |
      // 检查调用中的关键字参数名称
      methodInvocation.getAKeyword().getArg() = parameterName and
      
      // 确认该参数名存在于子类方法的参数列表中
      childMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // 确认该参数名不存在于父类方法的参数列表中
      not parentMethod.getScope().getAnArg().(Name).getId() = parameterName and
      
      // 构建问题描述
      errorDescription = "an argument named '" + parameterName + "'"
    )
  )
select parentMethod,  // 选择父类方法作为主要结果
  "Overridden method signature does not match $@, where it is passed " + errorDescription +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,  // 生成描述性错误消息
  childMethod.descriptiveString()  // 提供子类方法的详细描述