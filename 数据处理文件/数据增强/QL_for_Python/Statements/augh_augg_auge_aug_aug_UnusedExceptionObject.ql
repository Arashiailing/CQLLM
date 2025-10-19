/**
 * @name Unused exception object
 * @description Detects locations where exception objects are instantiated
 *              but never utilized, which may indicate programming mistakes
 *              or unnecessary code fragments.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建但未使用的异常实例
from Call unusedExceptionCreation
where
  // 确认调用指向一个继承自Exception的类
  exists(ClassValue exceptionClass | 
    unusedExceptionCreation.getFunc().pointsTo(exceptionClass) and
    exceptionClass.getASuperType() = ClassValue::exception()
  ) and
  // 验证异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt isolatedStatement | 
    isolatedStatement.getValue() = unusedExceptionCreation
  )
select unusedExceptionCreation, "Exception object created but not used. Consider raising the exception or removing this statement."