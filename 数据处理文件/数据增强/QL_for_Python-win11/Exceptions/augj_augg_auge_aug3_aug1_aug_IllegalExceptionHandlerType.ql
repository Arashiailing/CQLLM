/**
 * @name Non-Exception Type in except Clause
 * @description Detects exception handlers that specify non-exception types,
 *              which are ineffective because they cannot catch any thrown exceptions.
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

// Identify exception handlers and analyze their exception types
from ExceptFlowNode handlerNode, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode typeOrigin, string typeDescription
where
  // Establish relationship between handler and processed exception
  handlerNode.handledException(caughtType, exceptionClass, typeOrigin) and
  (
    // Case 1: Type is a class but not a valid exception type
    exists(ClassValue nonExceptionClass | 
      nonExceptionClass = caughtType and
      not nonExceptionClass.isLegalExceptionType() and
      not nonExceptionClass.failedInference(_) and
      typeDescription = "class '" + nonExceptionClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class at all
    (
      not caughtType instanceof ClassValue and
      typeDescription = "instance of '" + exceptionClass.getName() + "'"
    )
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOrigin, typeDescription