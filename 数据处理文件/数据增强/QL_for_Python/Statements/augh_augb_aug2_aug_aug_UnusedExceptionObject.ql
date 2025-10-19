/**
 * @name Unused exception object
 * @description Detects locations where exception objects are instantiated
 *              but never utilized, which may indicate programming errors
 *              or dead code that should be removed.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建了异常对象但没有使用的代码位置
from Call unusedExceptionCall, ClassValue targetExceptionClass
where
  // 确认调用目标是异常类实例化
  unusedExceptionCall.getFunc().pointsTo(targetExceptionClass) and
  // 验证目标类是Exception或其子类
  targetExceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象创建后未被使用（仅作为独立语句存在）
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCall
  )
select unusedExceptionCall, "Exception object created but not used. Consider raising the exception or removing this statement."