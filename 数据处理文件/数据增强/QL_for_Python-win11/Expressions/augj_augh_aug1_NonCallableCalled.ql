/**
 * @name Non-callable called
 * @description Detects code that attempts to call objects which are not callable,
 *              leading to runtime TypeError exceptions.
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

// 定义查询变量：调用表达式、目标值、目标类、函数表达式和源节点
from Call callExpression, Value targetValue, ClassValue targetClass, Expr funcExpression, AstNode sourceNode
where
  // 第一部分：建立调用表达式与函数表达式的关联，并获取其指向的值
  funcExpression = callExpression.getFunc() and
  funcExpression.pointsTo(targetValue, sourceNode) and
  
  // 第二部分：获取值所属的类并验证其不可调用性
  targetClass = targetValue.getClass() and
  not targetClass.isCallable() and
  
  // 第三部分：确保类型推断成功且类不包含__get__属性
  not targetClass.failedInference(_) and
  not targetClass.hasAttribute("__get__") and
  
  // 第四部分：排除特定情况：None值和在raise语句中使用NotImplemented
  not targetValue = Value::named("None") and
  not use_of_not_implemented_in_raise(_, funcExpression)
select callExpression, "Call to a $@ of $@.", sourceNode, "non-callable", targetClass, targetClass.toString()