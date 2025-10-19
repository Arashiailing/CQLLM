/**
 * @name Unused exception object
 * @description Detects locations where exception objects are instantiated
 *              but never utilized, which may indicate programming mistakes or dead code.
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
from Call unusedExceptionCreation, ClassValue exceptionClass
where
  // 确认调用指向一个异常类
  unusedExceptionCreation.getFunc().pointsTo(exceptionClass) and
  // 验证该类继承自Exception基类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象创建后未被使用，仅作为独立语句存在
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."