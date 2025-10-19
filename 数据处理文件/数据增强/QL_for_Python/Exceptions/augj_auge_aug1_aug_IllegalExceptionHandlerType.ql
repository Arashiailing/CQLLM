/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types,
 *              which are ineffective at runtime as they never match actual exceptions.
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

// Variables for analyzing exception handling constructs
from ExceptFlowNode handlerNode, Value capturedType, ClassValue exceptionClass, 
     ControlFlowNode originNode, string typeDescription
where
  // Verify the handler processes a specific exception type from the source
  handlerNode.handledException(capturedType, exceptionClass, originNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue invalidExceptionType | 
      invalidExceptionType = capturedType and
      not invalidExceptionType.isLegalExceptionType() and
      not invalidExceptionType.failedInference(_) and
      typeDescription = "class '" + invalidExceptionType.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not capturedType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescription