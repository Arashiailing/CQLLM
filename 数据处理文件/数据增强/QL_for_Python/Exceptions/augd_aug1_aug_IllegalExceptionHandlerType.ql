/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that reference non-exception types,
 *              which are ineffective at runtime since they never match actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Variables for analyzing exception handling constructs
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionType, 
     ControlFlowNode sourceNode, string typeInfo
where
  // Establish relationship between exception handler and its source
  exceptNode.handledException(caughtType, exceptionType, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = caughtType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      typeInfo = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + exceptionType.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeInfo