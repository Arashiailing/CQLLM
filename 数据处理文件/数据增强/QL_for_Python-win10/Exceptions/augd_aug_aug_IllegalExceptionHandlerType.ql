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
     Value caughtExceptionType, 
     ClassValue caughtClassValue, 
     ControlFlowNode typeSourceNode, 
     string typeDescription
where
  // Establish the exception handling relationship
  handlerNode.handledException(caughtExceptionType, caughtClassValue, typeSourceNode) and
  (
    // Case 1: Exception type is a class that doesn't inherit from BaseException
    exists(ClassValue illegalExceptionClass | 
      illegalExceptionClass = caughtExceptionType and
      not illegalExceptionClass.isLegalExceptionType() and
      not illegalExceptionClass.failedInference(_) and
      typeDescription = "class '" + illegalExceptionClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class (e.g., an instance)
    not caughtExceptionType instanceof ClassValue and
    typeDescription = "instance of '" + caughtClassValue.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeSourceNode, 
  typeDescription