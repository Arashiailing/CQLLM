/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers using non-exception types, rendering them ineffective for catching actual exceptions.
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

from ExceptFlowNode exceptionHandlerNode, 
     Value exceptionType, 
     ClassValue exceptionClassValue, 
     ControlFlowNode typeOriginNode, 
     string typeInfoDescription
where
  // Establish exception handling context
  exceptionHandlerNode.handledException(exceptionType, exceptionClassValue, typeOriginNode) and
  (
    // Case 1: Exception type is a non-inheriting class
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeInfoDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: Exception type is a non-class instance
    not exceptionType instanceof ClassValue and
    typeInfoDescription = "instance of '" + exceptionClassValue.getName() + "'"
  )
select exceptionHandlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOriginNode, 
  typeInfoDescription