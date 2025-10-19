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

// Variables for analyzing exception handling constructs
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string typeDesc
where
  // Verify the handler processes a specific exception type from the source
  exceptNode.handledException(caughtType, exceptionClass, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue nonExceptType | 
      nonExceptType = caughtType and
      not nonExceptType.isLegalExceptionType() and
      not nonExceptType.failedInference(_) and
      typeDesc = "class '" + nonExceptType.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not caughtType instanceof ClassValue and
    typeDesc = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDesc