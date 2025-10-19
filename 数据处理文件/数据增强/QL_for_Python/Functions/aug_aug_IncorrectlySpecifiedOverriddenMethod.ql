/**
 * @name 重写方法签名与使用不匹配
 * @description 检测方法签名与其重写方法签名以及调用参数不匹配的情况，
 *              这种不匹配可能导致运行时错误。
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python库，用于处理Python代码的查询
import Expressions.CallArgs  // 导入表达式调用参数库，用于处理函数调用参数

from Call methodInvocation, FunctionValue parentMethod, FunctionValue childMethod, string problemDescription  // 从方法调用、父类方法、子类方法和问题描述字符串中选择数据
where
  // 基本条件：排除构造函数并确保存在重写关系
  not parentMethod.getName() = "__init__" and  // 排除构造函数 '__init__'
  childMethod.overrides(parentMethod) and  // 确保 'childMethod' 是 'parentMethod' 的重写方法
  
  // 调用条件：获取重写方法的调用节点并验证参数
  methodInvocation = childMethod.getAMethodCall().getNode() and  // 获取重写方法的调用节点
  correct_args_if_called_as_method(methodInvocation, childMethod) and  // 检查如果作为方法调用时，参数是否正确
  
  // 参数不匹配条件：检查参数数量或名称不匹配
  (
    // 参数数量不匹配情况
    (
      arg_count(methodInvocation) + 1 < parentMethod.minParameters() and problemDescription = "too few arguments"  // 如果参数数量少于最小参数数量，标记为"参数过少"
      or
      arg_count(methodInvocation) >= parentMethod.maxParameters() and problemDescription = "too many arguments"  // 如果参数数量多于最大参数数量，标记为"参数过多"
    )
    or
    // 参数名称不匹配情况
    exists(string paramName |
      methodInvocation.getAKeyword().getArg() = paramName and  // 检查调用中的关键字参数名称
      childMethod.getScope().getAnArg().(Name).getId() = paramName and  // 检查重写方法中的参数名称
      not parentMethod.getScope().getAnArg().(Name).getId() = paramName and  // 检查原始方法中是否没有该参数名称
      problemDescription = "an argument named '" + paramName + "'"  // 标记为"存在一个名为 'paramName' 的参数"
    )
  )
select parentMethod,  // 选择原始方法
  "Overridden method signature does not match $@, where it is passed " + problemDescription +
    ". Overriding method $@ matches the call.", methodInvocation, "call", childMethod,  // 生成问题描述，指出签名不匹配和传递的问题
  childMethod.descriptiveString()  // 提供重写方法的描述性字符串