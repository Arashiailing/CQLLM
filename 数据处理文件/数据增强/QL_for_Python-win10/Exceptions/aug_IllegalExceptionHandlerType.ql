/**
 * @name Non-exception in 'except' clause
 * @description Detects when an exception handler specifies a non-exception type,
 *              which will never handle any actual exception at runtime.
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

// Define variables for analyzing exception handling constructs
from ExceptFlowNode exceptNode, Value exceptionType, ClassValue exceptionClass, 
     ControlFlowNode exceptionOrigin, string exceptionDescription
where
  // Verify that the exception node handles a specific exception type from the origin
  exceptNode.handledException(exceptionType, exceptionClass, exceptionOrigin) and
  (
    // Case 1: The exception type is a class value but not a legal exception type
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = exceptionType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      exceptionDescription = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Case 2: The exception type is not a class value at all
    not exceptionType instanceof ClassValue and
    exceptionDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, exceptionDescription