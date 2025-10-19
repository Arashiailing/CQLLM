/**
 * @name Unused exception object
 * @description Detects instances where exception objects are created but
 *              not utilized, indicating potential programming oversights
 *              or dead code that requires review and remediation.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 查找创建但未使用的异常对象实例
from Call unusedExnCreation, ClassValue exnClass
where
  // 验证该调用是异常类的实例化
  unusedExnCreation.getFunc().pointsTo(exnClass) and
  // 确认该类继承自Exception或其子类
  exnClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象创建后未被使用（仅作为独立表达式语句存在）
  exists(ExprStmt standaloneExprStmt | 
    standaloneExprStmt.getValue() = unusedExnCreation
  )
select unusedExnCreation, "Exception object created but not used. Consider raising the exception or removing this statement."