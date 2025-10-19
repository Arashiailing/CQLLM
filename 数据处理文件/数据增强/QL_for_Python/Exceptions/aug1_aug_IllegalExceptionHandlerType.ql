/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types,
 *              which are ineffective at runtime as they never match actual exceptions.
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

// Variables for analyzing exception handling constructs
from ExceptFlowNode exceptionHandler, Value handledType, ClassValue exceptionClass, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Verify the handler processes a specific exception type from the source
  exceptionHandler.handledException(handledType, exceptionClass, exceptionSource) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue nonExceptionType | 
      nonExceptionType = handledType and
      not nonExceptionType.isLegalExceptionType() and
      not nonExceptionType.failedInference(_) and
      typeDescription = "class '" + nonExceptionType.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription