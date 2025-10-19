/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types,
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

// Identify ineffective exception handlers that reference non-exception types
from ExceptFlowNode exceptionHandler, Value handledType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string typeInfo
where
  // Establish connection between exception handler and its handled type
  exceptionHandler.handledException(handledType, exceptionClass, sourceNode) and
  (
    // Case 1: The type is a class but not a valid exception class
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = handledType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeInfo = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: The type is not a class at all
    not handledType instanceof ClassValue and
    typeInfo = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeInfo