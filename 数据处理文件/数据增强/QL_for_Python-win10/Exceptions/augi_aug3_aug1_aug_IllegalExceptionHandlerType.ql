/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types,
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

// Variables for analyzing exception handling patterns
from ExceptFlowNode exceptHandler, Value capturedValue, ClassValue exceptionClass, 
     ControlFlowNode exceptionOrigin, string typeInfo
where
  // Establish connection between exception handler and its source
  exceptHandler.handledException(capturedValue, exceptionClass, exceptionOrigin) and
  (
    // Check for invalid exception class types
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = capturedValue and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      typeInfo = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Handle cases where captured value is not a class
    not capturedValue instanceof ClassValue and
    typeInfo = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, typeInfo