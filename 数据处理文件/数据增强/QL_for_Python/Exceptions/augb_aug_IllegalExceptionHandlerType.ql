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

// Analyze exception handling constructs for invalid exception types
from ExceptFlowNode handler, Value handledType, ClassValue exceptionClass, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Ensure the handler processes a specific exception type from the source
  handler.handledException(handledType, exceptionClass, exceptionSource) and
  (
    // Case 1: Exception type is a class but not a valid exception class
    exists(ClassValue invalidClass | 
      invalidClass = handledType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class at all
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select handler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription