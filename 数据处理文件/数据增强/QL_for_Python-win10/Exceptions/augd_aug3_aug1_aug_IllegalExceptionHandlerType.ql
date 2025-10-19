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

// Primary variables for analyzing exception handling constructs
from ExceptFlowNode exceptHandler, Value capturedType, ClassValue exceptionType, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Establish the relationship between exception handler and its source
  exceptHandler.handledException(capturedType, exceptionType, exceptionSource)
  and
  (
    // Case 1: Handler specifies a class that is not a valid exception type
    exists(ClassValue invalidExceptionType | 
      invalidExceptionType = capturedType and
      not invalidExceptionType.isLegalExceptionType() and
      not invalidExceptionType.failedInference(_) and
      typeDescription = "class '" + invalidExceptionType.getName() + "'"
    )
    or
    // Case 2: Handler specifies a non-class value (instance instead of class)
    not capturedType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionType.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription