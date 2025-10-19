/**
 * @name Unused exception object
 * @description Identifies code locations where an exception object is instantiated
 *              but never utilized, indicating potential programming errors or dead code.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建异常对象但未使用的代码位置
from Call unusedExceptionCall
where
  // 验证调用是否实例化了一个异常类（Exception或其子类）
  exists(ClassValue exceptionClass |
    unusedExceptionCall.getFunc().pointsTo(exceptionClass) and
    exceptionClass.getASuperType() = ClassValue::exception()
  ) and
  // 确认异常对象创建后未被使用，仅作为独立语句存在
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCall
  )
select unusedExceptionCall, "Exception object created but not used. Consider raising the exception or removing this statement."