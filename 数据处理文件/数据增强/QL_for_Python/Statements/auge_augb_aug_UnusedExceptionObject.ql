/**
 * @name Unused exception object
 * @description Identifies exception objects that are created but never utilized.
 *              Constructing an exception object without raising it or using it
 *              for any other purpose is usually indicative of a programming mistake.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python

// 查找创建了异常对象但未使用的代码位置
from Call exceptionCreation, ClassValue exceptionClass
where
  // 验证调用指向一个异常类且该类是Python异常类的子类
  exceptionCreation.getFunc().pointsTo(exceptionClass) and
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt standaloneStmt | 
    standaloneStmt.getValue() = exceptionCreation
  )
select exceptionCreation, "Instantiating an exception, but not raising it, has no effect."