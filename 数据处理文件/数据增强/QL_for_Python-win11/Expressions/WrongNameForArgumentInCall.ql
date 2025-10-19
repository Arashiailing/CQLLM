/**
 * @name Wrong name for an argument in a call
 * @description Using a named argument whose name does not correspond to a
 *              parameter of the called function or method, will result in a
 *              TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-argument
 */

import python  // 导入Python库，用于处理Python代码的解析和分析
import Expressions.CallArgs  // 导入表达式调用参数模块，用于处理函数或方法调用中的参数

// 定义查询，查找非法命名的参数
from Call call, FunctionObject func, string name
where
  illegally_named_parameter_objectapi(call, func, name) and  // 检查调用中是否存在非法命名的参数
  not func.isAbstract() and  // 确保函数不是抽象的
  not exists(FunctionObject overridden |  // 确保没有重载的函数具有相同的参数名
    func.overrides(overridden) and overridden.getFunction().getAnArg().(Name).getId() = name
  )
select call, "Keyword argument '" + name + "' is not a supported parameter name of $@.", func,  // 选择调用、错误信息和函数对象
  func.descriptiveString()  // 获取函数的描述性字符串
