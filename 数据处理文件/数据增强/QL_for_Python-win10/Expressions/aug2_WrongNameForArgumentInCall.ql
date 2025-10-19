/**
 * @name Incorrect keyword argument name in function call
 * @description This query identifies function calls where a named argument
 *              does not match any parameter of the target function, which
 *              will cause a TypeError at runtime when the code is executed.
 * @kind problem
 * @tags reliability
 *       correctness
 *       external/cwe/cwe-628
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/call/wrong-named-argument
 */

import python  // 导入Python分析库，提供Python代码的基础分析功能
import Expressions.CallArgs  // 导入调用参数处理模块，用于分析函数调用中的参数

// 查询定义：检测使用了错误命名参数的函数调用
from Call invocation, FunctionObject targetFunction, string argName
where
  // 检查调用中是否存在非法命名的参数
  illegally_named_parameter_objectapi(invocation, targetFunction, argName) and
  // 排除抽象函数，因为它们可能没有完整的参数定义
  not targetFunction.isAbstract() and
  // 确保错误不是由于继承关系引起的
  // 检查是否存在父类方法定义了该参数名
  not exists(FunctionObject parentMethod |
    targetFunction.overrides(parentMethod) and 
    parentMethod.getFunction().getAnArg().(Name).getId() = argName
  )
select invocation, "Keyword argument '" + argName + "' is not a supported parameter name of $@.", targetFunction,
  targetFunction.descriptiveString()  // 提供目标函数的描述性信息