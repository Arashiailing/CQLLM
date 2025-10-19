/**
 * @name Non-callable called
 * @description Identifies instances where non-callable objects are invoked,
 *              which would result in a TypeError during execution.
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
  // 步骤1：建立调用表达式与函数表达式的关联，并获取其指向的值
  functionExpr = invocationExpr.getFunc() and
  functionExpr.pointsTo(calledValue, originNode) and
  
  // 步骤2：获取值所属的类并验证其不可调用性
  calledClass = calledValue.getClass() and
  not calledClass.isCallable() and
  
  // 步骤3：确保类型推断成功且类不包含__get__属性
  not calledClass.failedInference(_) and
  not calledClass.hasAttribute("__get__") and
  
  // 步骤4：排除特定情况：None值和在raise语句中使用NotImplemented
  not calledValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionExpr)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", calledClass, calledClass.toString()