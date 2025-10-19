/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types,
 *              which are ineffective at catching actual runtime exceptions.
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

// Identify exception handlers with non-exception types that won't catch runtime exceptions
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string typeLabel
where
  // Verify the exception handler processes a specific type from the source
  exceptNode.handledException(caughtType, exceptionClass, sourceNode) and
  (
    // First case: Exception type is a class but not a valid exception class
    exists(ClassValue invalidClass | 
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeLabel = "class '" + invalidClass.getName() + "'"
    )
    or
    // Second case: Exception type is not a class at all
    not caughtType instanceof ClassValue and
    typeLabel = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeLabel