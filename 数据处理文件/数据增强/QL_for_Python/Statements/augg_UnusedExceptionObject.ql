/**
 * @name Unused exception object
 * @description Detects instances where an exception object is instantiated but never utilized,
 *              which typically indicates dead code or a programming error.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // 导入Python库，用于分析Python代码

// 定义查询语句，识别未使用的异常对象实例化
from Call exceptionCall, ClassValue exceptionClass
where
  // 验证调用的目标指向一个异常类
  exceptionCall.getFunc().pointsTo(exceptionClass) and
  // 确认该类继承自基础异常类或其子类
  exceptionClass.getASuperType() = ClassValue::exception() and
  // 检查异常对象仅作为独立表达式语句存在，未被进一步使用
  exists(ExprStmt exprStmt | exprStmt.getValue() = exceptionCall)
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."  // 输出符合条件的异常实例化调用及警告信息