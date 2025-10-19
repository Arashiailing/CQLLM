/**
 * @name Unused exception object
 * @description An exception object is created, but is not used.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python分析库，提供代码分析的基础功能

// 查找创建了异常对象但未使用的代码位置
from Call unusedExceptionCreation, ClassValue exceptionType
where
  // 验证调用指向一个异常类
  unusedExceptionCreation.getFunc().pointsTo(exceptionType) and
  // 确保该类继承自Python基础异常类
  exceptionType.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt expressionStatement | 
    expressionStatement.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Instantiating an exception, but not raising it, has no effect."  // 输出警告信息