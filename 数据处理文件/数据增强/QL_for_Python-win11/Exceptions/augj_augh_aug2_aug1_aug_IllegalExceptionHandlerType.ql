/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types,
 *              making them ineffective for catching actual exceptions.
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
from ExceptFlowNode exceptionHandler, Value caughtType, ClassValue exceptionBase, 
     ControlFlowNode sourceNode, string typeInfo
where
  // Ensure the handler processes a specific exception type from the source
  exceptionHandler.handledException(caughtType, exceptionBase, sourceNode) and
  (
    // First scenario: Type is a class but not a valid exception
    exists(ClassValue invalidExceptionType | 
      invalidExceptionType = caughtType and
      not invalidExceptionType.isLegalExceptionType() and
      not invalidExceptionType.failedInference(_) and
      typeInfo = "class '" + invalidExceptionType.getName() + "'"
    )
    or
    // Second scenario: Type is not a class value
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + exceptionBase.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeInfo