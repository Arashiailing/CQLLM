/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would raise a TypeError at runtime.
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

// 定义变量：调用表达式、被引用值、值类、被调用者表达式和源节点
from Call invocationExpr, Value referencedValue, ClassValue valueClass, Expr calleeExpr, AstNode originNode
where
  // 第一组：获取调用表达式和被调用者，并确定被调用者引用的值
  calleeExpr = invocationExpr.getFunc() and
  calleeExpr.pointsTo(referencedValue, originNode) and
  
  // 第二组：获取值所属的类并检查其可调用性
  valueClass = referencedValue.getClass() and
  not valueClass.isCallable() and
  
  // 第三组：排除特殊情况
  // 确保类型推断成功且类没有__get__属性
  not valueClass.failedInference(_) and
  not valueClass.hasAttribute("__get__") and
  
  // 排除None值和在raise语句中使用NotImplemented的情况
  not referencedValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, calleeExpr)
select invocationExpr, "Call to a $@ of $@.", originNode, "non-callable", valueClass, valueClass.toString()