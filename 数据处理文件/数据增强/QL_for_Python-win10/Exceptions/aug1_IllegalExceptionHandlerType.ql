/**
 * @name Non-exception in 'except' clause
 * @description An exception handler specifying a non-exception type will never handle any exception.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// 查询在异常处理中使用非异常类型的情况
from ExceptFlowNode exceptNode, Value exceptionType, ClassValue exceptionClass, 
     ControlFlowNode exceptionOrigin, string exceptionDescription
where
  // 异常节点处理了特定类型的异常
  exceptNode.handledException(exceptionType, exceptionClass, exceptionOrigin) and
  (
    // 情况1：异常类型是一个类，但不是合法的异常类
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = exceptionType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      exceptionDescription = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // 情况2：异常类型不是一个类，而是类的实例
    not exceptionType instanceof ClassValue and
    exceptionDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, exceptionDescription