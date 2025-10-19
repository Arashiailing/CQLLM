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

// 查找创建了异常对象但没有使用的代码位置
from Call unusedExceptionCreation, ClassValue exceptionClass
where
  // 条件1: 确认调用是创建一个异常类的实例
  unusedExceptionCreation.getFunc().pointsTo(exceptionClass) and
  // 条件2: 验证该类是Exception类或其子类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 条件3: 检查异常对象被创建后未被使用，仅作为独立语句存在
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."