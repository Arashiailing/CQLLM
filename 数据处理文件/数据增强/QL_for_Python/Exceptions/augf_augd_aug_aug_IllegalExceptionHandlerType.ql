/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types, making them ineffective at catching actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 *       types
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except */

import python

from ExceptFlowNode handlerNode,
     Value exceptionType,
     ClassValue exceptionClass,
     ControlFlowNode typeOriginNode,
     string typeDescriptor
where
  // Establish the exception handling relationship
  handlerNode.handledException(exceptionType, exceptionClass, typeOriginNode) and
  (
    // Case 1: Exception type is a class that doesn't inherit from BaseException
    exists(ClassValue invalidExceptionClass |
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescriptor = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class (e.g., an instance)
    not exceptionType instanceof ClassValue and
    typeDescriptor = "instance of '" + exceptionClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.",
  typeOriginNode,
  typeDescriptor