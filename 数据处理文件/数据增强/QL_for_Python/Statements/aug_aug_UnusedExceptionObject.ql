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

// 查找创建了异常对象但没有使用的代码
from Call exceptionInstanceCreation, ClassValue exceptionType
where
  // 验证调用是创建一个异常类的实例
  exceptionInstanceCreation.getFunc().pointsTo(exceptionType) and
  // 确保该类是Exception类或其子类
  exceptionType.getASuperType() = ClassValue::exception() and
  // 检查异常对象被创建后未被使用（仅作为独立语句存在）
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionInstanceCreation
  )
select exceptionInstanceCreation, "Exception object created but not used. Consider raising the exception or removing this statement."