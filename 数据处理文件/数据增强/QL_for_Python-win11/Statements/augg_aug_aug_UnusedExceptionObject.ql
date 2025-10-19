/**
 * @name Unused exception object
 * @description Detects instances where exception objects are created but never utilized,
 *              which may indicate programming oversights or dead code that should be addressed.
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
from Call exceptionCreationCall, ClassValue exceptionClass
where
  // 验证调用是创建一个异常类的实例
  exceptionCreationCall.getFunc().pointsTo(exceptionClass) and
  // 确保该类是Exception类或其子类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象被创建后未被使用（仅作为独立语句存在）
  exists(ExprStmt standaloneExpr | 
    standaloneExpr.getValue() = exceptionCreationCall
  )
select exceptionCreationCall, "Exception object created but not used. Consider raising the exception or removing this statement."