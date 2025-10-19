/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types,
 *              which are ineffective as they never match actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Enhanced variable naming for clarity
from ExceptFlowNode exceptionHandler, Value caughtExceptionType, ClassValue baseExceptionClass, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Core condition: Verify handler processes a specific exception type
  exceptionHandler.handledException(caughtExceptionType, baseExceptionClass, exceptionSource) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue invalidClass | 
      invalidClass = caughtExceptionType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not caughtExceptionType instanceof ClassValue and
    typeDescription = "instance of '" + baseExceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription