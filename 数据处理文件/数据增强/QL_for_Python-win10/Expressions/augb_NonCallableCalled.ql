/**
 * @name Non-callable called
 * @description Detects calls to objects that are not callable, which would result in a TypeError at runtime.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity high
 * @precision high
 * @id py/call-to-non-callable
 */

import python  // 导入Python代码分析库
import Exceptions.NotImplemented  // 导入NotImplemented异常处理模块

// 定义查询变量：调用节点、目标值、目标类、函数表达式和值来源
from Call callNode, Value targetValue, ClassValue targetClass, Expr funcExpr, AstNode valueOrigin
where
  // 步骤1：获取调用表达式及其指向的值
  funcExpr = callNode.getFunc() and
  funcExpr.pointsTo(targetValue, valueOrigin) and
  
  // 步骤2：获取目标值的类并检查其不可调用性
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 步骤3：排除特殊情况
  not targetClass.failedInference(_) and  // 类型推断成功
  not targetClass.hasAttribute("__get__") and  // 没有__get__属性
  not targetValue = Value::named("None") and  // 不是None值
  not use_of_not_implemented_in_raise(_, funcExpr)  // 不是在raise中使用NotImplemented
select callNode, "Call to a $@ of $@.", valueOrigin, "non-callable", targetClass, targetClass.toString()