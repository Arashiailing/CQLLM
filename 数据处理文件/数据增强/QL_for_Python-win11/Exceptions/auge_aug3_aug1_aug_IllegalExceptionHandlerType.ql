/**
 * @name Invalid Exception Type in 'except' Clause
 * @description Detects exception handlers that reference types which are not valid exceptions,
 *              rendering them ineffective as they cannot match any raised exception at runtime.
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

// Define variables for exception handler analysis
from ExceptFlowNode exceptHandler, Value capturedType, ClassValue exceptionCls, 
     ControlFlowNode exceptionSource, string typeDescription
where
  // Link the exception handler to the exception it handles
  exceptHandler.handledException(capturedType, exceptionCls, exceptionSource) and
  (
    // Check if the captured type is a class but not a valid exception
    exists(ClassValue invalidExceptionType | 
      invalidExceptionType = capturedType and
      not invalidExceptionType.isLegalExceptionType() and
      not invalidExceptionType.failedInference(_) and
      typeDescription = "class '" + invalidExceptionType.getName() + "'"
    )
    or
    // Check if the captured type is not a class at all
    not capturedType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionCls.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDescription