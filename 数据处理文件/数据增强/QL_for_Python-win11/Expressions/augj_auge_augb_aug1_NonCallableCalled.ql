/**
 * @name Non-callable called
 * @description Identifies attempts to invoke objects that are not callable,
 *              which would result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable */

import python  // 导入Python分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义变量：调用表达式、被调用对象、对象类、函数引用和源节点
from Call invocationExpr, Value calledObject, ClassValue objectClass, Expr functionReference, AstNode originNode
where
  // 关联调用表达式与被调用对象
  functionReference = invocationExpr.getFunc() and
  functionReference.pointsTo(calledObject, originNode) and
  
  // 检查被调用对象的类属性
  objectClass = calledObject.getClass() and
  not objectClass.isCallable() and
  not objectClass.failedInference(_) and
  
  // 排除描述符协议相关的类（具有__get__属性）
  not objectClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not calledObject = Value::named("None") and
  not use_of_not_implemented_in_raise(_, functionReference)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", objectClass, objectClass.toString()