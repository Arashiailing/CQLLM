/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that use non-exception types, rendering them ineffective
 *              for catching actual exceptions. This can lead to unhandled exceptions and unexpected
 *              program behavior.
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

from ExceptFlowNode exceptionHandler, 
     Value handledType, 
     ClassValue handledClass, 
     ControlFlowNode typeOriginNode, 
     string invalidTypeDescription
where
  // Establish the relationship between the exception handler and the type it handles
  exceptionHandler.handledException(handledType, handledClass, typeOriginNode) and
  (
    // Check if the handled type is a class that doesn't inherit from BaseException
    exists(ClassValue illegalExceptionClass | 
      illegalExceptionClass = handledType and
      not illegalExceptionClass.isLegalExceptionType() and
      not illegalExceptionClass.failedInference(_) and
      invalidTypeDescription = "class '" + illegalExceptionClass.getName() + "'"
    )
    or
    // Check if the handled type is not a class at all (e.g., an instance)
    not handledType instanceof ClassValue and
    invalidTypeDescription = "instance of '" + handledClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOriginNode, 
  invalidTypeDescription