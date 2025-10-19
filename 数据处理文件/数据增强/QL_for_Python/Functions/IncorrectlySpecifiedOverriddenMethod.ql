/**
 * @name Mismatch between signature and use of an overridden method
 * @description Method has a signature that differs from both the signature of its overriding methods and
 *              the arguments with which it is called, and if it were called, would be likely to cause an error.
 * @kind problem
 * @tags maintainability
 * @problem.severity recommendation
 * @sub-severity high
 * @precision high
 * @id py/inheritance/incorrect-overridden-signature
 */

import python  // 导入Python库，用于处理Python代码的查询
import Expressions.CallArgs  // 导入表达式调用参数库，用于处理函数调用参数

from Call call, FunctionValue func, FunctionValue overriding, string problem  // 从调用、函数值和问题字符串中选择数据
where
  not func.getName() = "__init__" and  // 排除构造函数 '__init__'
  overriding.overrides(func) and  // 确保 'overriding' 是 'func' 的重载方法
  call = overriding.getAMethodCall().getNode() and  // 获取重载方法的调用节点
  correct_args_if_called_as_method(call, overriding) and  // 检查如果作为方法调用时，参数是否正确
  (
    arg_count(call) + 1 < func.minParameters() and problem = "too few arguments"  // 如果参数数量少于最小参数数量，标记为“参数过少”
    or
    arg_count(call) >= func.maxParameters() and problem = "too many arguments"  // 如果参数数量多于最大参数数量，标记为“参数过多”
    or
    exists(string name |
      call.getAKeyword().getArg() = name and  // 检查调用中的关键字参数名称
      overriding.getScope().getAnArg().(Name).getId() = name and  // 检查重载方法中的参数名称
      not func.getScope().getAnArg().(Name).getId() = name and  // 检查原始方法中是否没有该参数名称
      problem = "an argument named '" + name + "'"  // 标记为“存在一个名为 'name' 的参数”
    )
  )
select func,  // 选择原始方法
  "Overridden method signature does not match $@, where it is passed " + problem +
    ". Overriding method $@ matches the call.", call, "call", overriding,  // 生成问题描述，指出签名不匹配和传递的问题
  overriding.descriptiveString()  // 提供重载方法的描述性字符串
