/**
 * @name Unused exception object
 * @description Identifies code locations where exception objects are instantiated
 *              but never utilized, potentially indicating programming mistakes
 *              or obsolete code sections.
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
  // 验证该调用是实例化一个异常类
  exceptionCreationCall.getFunc().pointsTo(exceptionClass) and
  // 确认该类继承自Exception或其子类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象被创建后未被使用（仅作为独立语句存在）
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionCreationCall
  )
select exceptionCreationCall, "Exception object created but not used. Consider raising the exception or removing this statement."