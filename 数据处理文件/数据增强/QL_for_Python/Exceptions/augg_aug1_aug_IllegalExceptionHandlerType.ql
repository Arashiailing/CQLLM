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

// Variables for analyzing ineffective exception handling constructs
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionBaseClass, 
     ControlFlowNode exceptionOrigin, string invalidTypeDesc
where
  // Verify the handler processes a specific exception type from the source
  exceptNode.handledException(caughtType, exceptionBaseClass, exceptionOrigin) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = caughtType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      invalidTypeDesc = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not caughtType instanceof ClassValue and
    invalidTypeDesc = "instance of '" + exceptionBaseClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, invalidTypeDesc