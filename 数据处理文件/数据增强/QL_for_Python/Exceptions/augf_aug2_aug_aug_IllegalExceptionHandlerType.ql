/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that use non-exception types which are incapable of catching actual exceptions
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

from ExceptFlowNode exceptionHandler,
     Value caughtType,
     ClassValue caughtClass,
     ControlFlowNode typeSource,
     string typeInfo
where
  // Establish the relationship between exception handler and caught exception
  exceptionHandler.handledException(caughtType, caughtClass, typeSource) and
  (
    // Scenario 1: Exception type is a class that doesn't inherit from BaseException
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeInfo = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: Exception type is not a class (e.g., an instance)
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + caughtClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeSource, 
  typeInfo