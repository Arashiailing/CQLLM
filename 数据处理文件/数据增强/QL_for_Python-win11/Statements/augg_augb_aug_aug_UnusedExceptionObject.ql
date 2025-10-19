/**
 * @name Unused exception object
 * @description Detects code locations where an exception object is created
 *              but never used, suggesting potential programming mistakes or dead code.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建异常对象但未使用的代码位置
from Call exceptionCreationCall
where
  // 检查调用是否创建了一个异常类的实例
  exists(ClassValue exceptionType |
    exceptionCreationCall.getFunc().pointsTo(exceptionType) and
    // 验证该类是Exception类或其子类
    exceptionType.getASuperType() = ClassValue::exception()
  ) and
  // 检查异常对象被创建后未被使用，仅作为独立语句存在
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionCreationCall
  )
select exceptionCreationCall, "Exception object created but not used. Consider raising the exception or removing this statement."