/**
 * @name Unused exception object
 * @description Detects exception objects that are instantiated but never used.
 *              Creating an exception object without raising it or using it
 *              in any other way is typically a programming error.
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
from Call exceptionInstantiation, ClassValue exceptionType
where
  // 验证调用指向一个异常类
  exceptionInstantiation.getFunc().pointsTo(exceptionType) and
  // 确保该类是Python异常类的子类
  exceptionType.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt unusedStatement | 
    unusedStatement.getValue() = exceptionInstantiation
  )
select exceptionInstantiation, "Instantiating an exception, but not raising it, has no effect."  // 输出警告信息