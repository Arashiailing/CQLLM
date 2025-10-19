/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that use non-exception types,
 *              which are ineffective at runtime since they never match actual exceptions.
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

// Variables for analyzing exception handlers
from ExceptFlowNode exceptHandler, Value caughtValue, ClassValue exceptionClass, 
     ControlFlowNode typeSource, string typeDescription
where
  // Link the exception handler to the type being caught
  exceptHandler.handledException(caughtValue, exceptionClass, typeSource) and
  (
    // Check if caught type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtValue and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Check if caught type is not a class value at all
    not caughtValue instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeSource, typeDescription