/**
 * @name Unused exception object
 * @description Detects instances where exception objects are created but never used,
 *              which may indicate programming errors or dead code.
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
from Call unusedExceptionCreation, ClassValue createdExceptionClass
where
  // 确认调用是创建一个异常类的实例
  unusedExceptionCreation.getFunc().pointsTo(createdExceptionClass) and
  // 验证该类是Exception类或其子类
  createdExceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象被创建后未被使用（仅作为独立语句存在）
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."