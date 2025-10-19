/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types in their except clauses.
 *              These handlers are ineffective at runtime because they can never match actual exceptions.
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

// Primary variables for analyzing exception handlers
from ExceptFlowNode exceptHandler, Value capturedType, ClassValue exceptionClass, 
     ControlFlowNode originNode, string errorMessage
where
  // Establish the connection between exception handler and its captured type
  exceptHandler.handledException(capturedType, exceptionClass, originNode)
  and
  (
    // First case: Captured type is a class but not a valid exception class
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = capturedType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      errorMessage = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Second case: Captured type is not a class value at all
    not capturedType instanceof ClassValue and
    errorMessage = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, errorMessage