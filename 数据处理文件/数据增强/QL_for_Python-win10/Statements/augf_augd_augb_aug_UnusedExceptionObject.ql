/**
 * @name Unused exception object
 * @description Detects locations where exception objects are instantiated but never utilized.
 *              This usually represents a programming error because creating an exception
 *              without raising it or using it for any other purpose is meaningless.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python分析库，提供代码分析的基础功能

// 查找创建异常对象但未使用的代码位置
from Call exceptionCreation, ClassValue exceptionType
where
  // 确保调用指向一个异常类
  exceptionCreation.getFunc().pointsTo(exceptionType) and
  // 验证该类继承自Python内置异常基类
  exceptionType.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt exprStmt | 
    exprStmt.getValue() = exceptionCreation
  )
select exceptionCreation, "Instantiating an exception, but not raising it, has no effect."  // 输出警告信息