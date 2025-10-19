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

import python  // Python 代码分析基础库
import Expressions.CallArgs  // 函数调用参数处理库

from Call invocation, FunctionValue parentMethod, FunctionValue childMethod, string problemDescription
where
  // 排除构造函数（通常参数模式不同）
  not parentMethod.getName() = "__init__" and
  
  // 确认方法重写关系
  childMethod.overrides(parentMethod) and
  
  // 获取子类方法调用节点并验证参数有效性
  invocation = childMethod.getAMethodCall().getNode() and
  correct_args_if_called_as_method(invocation, childMethod) and
  
  // 检查参数不匹配的三种情况
  (
    // 情况1：传递参数少于基类方法最小参数数量
    arg_count(invocation) + 1 < parentMethod.minParameters() and 
    problemDescription = "too few arguments"
    
    or
    
    // 情况2：传递参数超过基类方法最大参数数量
    arg_count(invocation) >= parentMethod.maxParameters() and 
    problemDescription = "too many arguments"
    
    or
    
    // 情况3：存在基类不接受的关键字参数
    exists(string paramName |
      // 检查调用中的关键字参数名称
      invocation.getAKeyword().getArg() = paramName and
      
      // 确认参数名存在于子类方法参数列表
      childMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // 确认参数名不存在于基类方法参数列表
      not parentMethod.getScope().getAnArg().(Name).getId() = paramName and
      
      // 构建问题描述
      problemDescription = "an argument named '" + paramName + "'"
    )
  )
select parentMethod,  // 选择基类方法作为主要结果
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", invocation, "call", childMethod,  // 生成描述性错误消息
  childMethod.descriptiveString()  // 提供子类方法的详细描述