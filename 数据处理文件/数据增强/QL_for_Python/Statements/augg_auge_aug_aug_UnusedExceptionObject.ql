/**
 * @name Unused exception object
 * @description Identifies code locations where exception instances are created
 *              but never utilized, potentially indicating programming errors
 *              or redundant code segments.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建了异常实例但没有使用的代码位置
from Call exceptionInstanceCreation
where
  // 验证调用是创建一个异常类的实例
  exists(ClassValue exceptionType | 
    exceptionInstanceCreation.getFunc().pointsTo(exceptionType) and
    // 确保该类继承自Exception基类
    exceptionType.getASuperType() = ClassValue::exception()
  ) and
  // 检查异常对象仅作为独立表达式语句存在，未被使用
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionInstanceCreation
  )
select exceptionInstanceCreation, "Exception object created but not used. Consider raising the exception or removing this statement."