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
from Call exceptionCall, ClassValue exceptionClass
where
  // 验证调用指向一个异常类
  exceptionCall.getFunc().pointsTo(exceptionClass) and
  // 确保该类是Python异常类的子类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt stmt | stmt.getValue() = exceptionCall)
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."  // 输出警告信息