/**
 * @name Mismatch between signature and use of an overriding method
 * @description Method has a different signature from the overridden method and, if it were called, would be likely to cause an error.
 * @kind problem
 * @tags maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision high
 * @id py/inheritance/incorrect-overriding-signature
 */

import python  // 导入Python库，用于分析Python代码
import Expressions.CallArgs  // 导入表达式调用参数模块

// 定义查询语句，查找方法签名不匹配的问题
from Call call, FunctionValue func, FunctionValue overridden, string problem
where
  func.overrides(overridden) and  // 检查func是否重写了overridden方法
  (
    wrong_args(call, func, _, problem) and  // 检查调用时参数是否错误
    correct_args_if_called_as_method(call, overridden)  // 检查如果作为方法调用时参数是否正确
    or
    exists(string name |  // 检查是否存在非法命名的参数
      illegally_named_parameter(call, func, name) and  // 检查是否有非法命名的参数
      problem = "an argument named '" + name + "'" and  // 设置问题描述为非法命名的参数名
      overridden.getScope().getAnArg().(Name).getId() = name  // 检查被重写的方法中是否有相同名称的参数
    )
  )
select func,  // 选择重写的方法
  "Overriding method signature does not match $@, where it is passed " + problem +
    ". Overridden method $@ is correctly specified.", call, "here", overridden,
  overridden.descriptiveString()  // 输出问题描述和相关方法信息
