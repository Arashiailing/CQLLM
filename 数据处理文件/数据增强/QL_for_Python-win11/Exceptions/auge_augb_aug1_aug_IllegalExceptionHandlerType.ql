/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types.
 *              Such handlers are ineffective at runtime since they cannot match
 *              any actual exceptions that might be raised.
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

// Variables for analyzing exception handlers and their types
from ExceptFlowNode exceptHandler, Value caughtExceptionType, ClassValue actualExceptionType, 
     ControlFlowNode exceptionSourceNode, string exceptionTypeMessage
where
  // Link the exception handler with the type it attempts to catch
  exceptHandler.handledException(caughtExceptionType, actualExceptionType, exceptionSourceNode) and
  (
    // Check if the caught type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtExceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      exceptionTypeMessage = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Check if the caught type is not a class value at all
    not caughtExceptionType instanceof ClassValue and
    exceptionTypeMessage = "instance of '" + actualExceptionType.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSourceNode, exceptionTypeMessage