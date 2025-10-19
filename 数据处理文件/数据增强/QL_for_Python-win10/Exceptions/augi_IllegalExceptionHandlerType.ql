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

// 查询异常处理节点、异常类型、异常类、控制流节点和描述信息
from ExceptFlowNode exceptNode, Value exceptionType, ClassValue exceptionClass, ControlFlowNode sourceNode, string description
where
  // 关联异常处理节点与其处理的异常类型、异常类和来源节点
  exceptNode.handledException(exceptionType, exceptionClass, sourceNode) and
  (
    // 情况1：异常类型是类但不是合法异常类型
    exists(ClassValue invalidClass | 
      invalidClass = exceptionType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      description = "class '" + invalidClass.getName() + "'"
    )
    or
    // 情况2：异常类型不是类实例
    not exceptionType instanceof ClassValue and
    description = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(), 
  "Non-exception $@ in exception handler which will never match raised exception.", sourceNode, description