/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handling blocks that reference non-exception types,
 *              making them ineffective since they cannot catch actual exceptions at runtime.
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

// Key variables for analyzing exception handling constructs
from ExceptFlowNode exceptHandler, Value handledType, ClassValue sourceExceptionClass, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Establish the relationship between the exception handler and its source
  exceptHandler.handledException(handledType, sourceExceptionClass, exceptionSource)
  and
  (
    // Scenario 1: Handler uses a class that is not a valid exception type
    exists(ClassValue invalidExceptionType | 
      invalidExceptionType = handledType and
      not invalidExceptionType.isLegalExceptionType() and
      not invalidExceptionType.failedInference(_) and
      typeDescription = "class '" + invalidExceptionType.getName() + "'"
    )
    or
    // Scenario 2: Handler uses a non-class value (instance instead of class)
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + sourceExceptionClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription