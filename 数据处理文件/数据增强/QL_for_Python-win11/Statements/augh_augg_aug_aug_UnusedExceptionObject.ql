/**
 * @name Unused exception object
 * @description Identifies code locations where exception objects are instantiated
 *              but never utilized, suggesting potential programming oversights
 *              or dead code that should be reviewed and addressed.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建但未使用的异常对象实例
from Call unusedExceptionCall, ClassValue exceptionType
where
  // 确认该调用是异常类的实例化
  unusedExceptionCall.getFunc().pointsTo(exceptionType) and
  // 验证该类继承自Exception或其子类
  exceptionType.getASuperType() = ClassValue::exception() and
  // 检查异常对象创建后未被使用（仅作为独立表达式语句存在）
  exists(ExprStmt unusedExprStmt | 
    unusedExprStmt.getValue() = unusedExceptionCall
  )
select unusedExceptionCall, "Exception object created but not used. Consider raising the exception or removing this statement."