/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that use non-exception types,
 *              rendering them ineffective as they can never match actual exceptions.
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
from ExceptFlowNode handlerNode, Value exceptionType, ClassValue baseClass, 
     ControlFlowNode originNode, string typeDescription
where
  // Verify the handler processes a specific exception type from the source
  handlerNode.handledException(exceptionType, baseClass, originNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not exceptionType instanceof ClassValue and
    typeDescription = "instance of '" + baseClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescription