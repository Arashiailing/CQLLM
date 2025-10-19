/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types, making them ineffective at catching any actual exceptions.
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

from ExceptFlowNode handlerNode, 
     Value caughtType, 
     ClassValue caughtClass, 
     ControlFlowNode typeSourceNode, 
     string typeDescription
where
  // First, establish the exception handling relationship
  handlerNode.handledException(caughtType, caughtClass, typeSourceNode) and
  (
    // Scenario 1: The exception type is a class that doesn't inherit from BaseException
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: The exception type is not a class at all (e.g., an instance)
    not caughtType instanceof ClassValue and
    typeDescription = "instance of '" + caughtClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeSourceNode, 
  typeDescription