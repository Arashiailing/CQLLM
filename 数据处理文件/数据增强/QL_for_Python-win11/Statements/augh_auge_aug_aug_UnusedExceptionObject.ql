/**
 * @name Unused exception object
 * @description Identifies code locations where exception objects are instantiated but never utilized,
 *              which could indicate programming errors or redundant code.
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
from Call unusedExceptionCreation
where
  // 确保调用是创建一个异常类的实例
  exists(ClassValue exceptionType | 
    unusedExceptionCreation.getFunc().pointsTo(exceptionType) and
    // 验证该类继承自Exception类
    exceptionType.getASuperType() = ClassValue::exception()
  ) and
  // 检查异常对象仅作为独立语句存在，没有被使用
  exists(ExprStmt standaloneExprStmt | 
    standaloneExprStmt.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."