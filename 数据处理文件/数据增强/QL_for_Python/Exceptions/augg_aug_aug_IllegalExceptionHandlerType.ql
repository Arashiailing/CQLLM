/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that use non-exception types,
 *              rendering them ineffective at catching actual exceptions.
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

from ExceptFlowNode exceptionHandler, 
     Value exceptionType, 
     ClassValue exceptionClass, 
     ControlFlowNode typeOriginNode, 
     string invalidTypeDescription
where
  // Establish the exception handling relationship
  exceptionHandler.handledException(exceptionType, exceptionClass, typeOriginNode) and
  (
    // Check for invalid exception classes that don't inherit from BaseException
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      invalidTypeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Identify non-class types used as exception handlers (e.g., instances)
    not exceptionType instanceof ClassValue and
    invalidTypeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOriginNode, 
  invalidTypeDescription