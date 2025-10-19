/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that catch non-exception types,
 *              rendering them ineffective as they cannot match any actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Variables representing components of exception handling structures
from ExceptFlowNode exceptHandler, Value exceptionType, ClassValue baseException, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Ensure the handler processes a specific exception type from the source
  exceptHandler.handledException(exceptionType, baseException, exceptionSource) and
  (
    // Scenario 1: Type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: Type is not a class value
    not exceptionType instanceof ClassValue and
    typeDescription = "instance of '" + baseException.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription