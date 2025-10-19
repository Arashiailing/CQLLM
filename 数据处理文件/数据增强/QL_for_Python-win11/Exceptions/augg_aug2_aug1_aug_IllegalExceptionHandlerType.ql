/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that utilize non-exception types,
 *              rendering them ineffective as they cannot match actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Variables representing components of exception handling constructs
from ExceptFlowNode handlerNode, Value caughtValue, ClassValue baseClass, 
     ControlFlowNode originNode, string typeDescription
where
  // Ensure the handler is associated with a specific exception type from its source
  handlerNode.handledException(caughtValue, baseClass, originNode) and
  (
    // Case 1: The type is a class but does not inherit from a valid exception base
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtValue and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: The type is not a class value
    not caughtValue instanceof ClassValue and
    typeDescription = "instance of '" + baseClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescription