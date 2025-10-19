/**
 * @name Non-callable called
 * @description Identifies instances where non-callable objects are invoked as functions,
 *              which would result in a TypeError at runtime.
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

// 定义变量：调用表达式、被调用值、被调用类、函数引用和源节点
from Call callExpression, Value targetValue, ClassValue targetClass, Expr funcReference, AstNode sourceNode
where
  // 获取调用表达式中的函数引用及其指向的值
  funcReference = callExpression.getFunc() and
  funcReference.pointsTo(targetValue, sourceNode) and
  
  // 检查被调用值的类是否不可调用
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 确保类型推断成功且类没有__get__属性
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  
  // 排除特定情况：None值和在raise语句中使用NotImplemented
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcReference)
select callExpression, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()