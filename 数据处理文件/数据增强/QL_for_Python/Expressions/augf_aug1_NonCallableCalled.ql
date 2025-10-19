/**
 * @name Non-callable called
 * @description Identifies instances where non-callable objects are invoked, leading to runtime TypeError exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python  // 导入Python分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义变量：调用表达式、被调用值、被调用类、函数表达式和源节点
from Call invocationExpr, Value calledValue, ClassValue calledClass, Expr functionExpr, AstNode originNode
where
  // 获取函数表达式并追踪其指向的值
  functionExpr = invocationExpr.getFunc() and
  functionExpr.pointsTo(calledValue, originNode) and
  
  // 检查值所属类是否不可调用
  calledClass = calledValue.getClass() and
  not calledClass.isCallable() and
  
  // 排除类型推断失败和具有__get__属性的类
  not calledClass.failedInference(_) and
  not calledClass.hasAttribute("__get__") and
  
  // 过滤掉特殊情况：None值和在raise语句中的NotImplemented使用
  not calledValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionExpr)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", calledClass, calledClass.toString()