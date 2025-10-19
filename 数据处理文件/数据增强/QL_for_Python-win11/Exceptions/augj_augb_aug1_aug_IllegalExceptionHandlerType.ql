/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types,
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

// Main components for exception handler analysis
from ExceptFlowNode exceptHandler, Value caughtType, ClassValue actualException, 
     ControlFlowNode typeOrigin, string diagnosticMessage
where
  // Link between exception handler and its caught exception type
  exceptHandler.handledException(caughtType, actualException, typeOrigin) and
  (
    // Scenario 1: Caught type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      diagnosticMessage = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: Caught type is not a class value
    not caughtType instanceof ClassValue and
    diagnosticMessage = "instance of '" + actualException.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOrigin, diagnosticMessage