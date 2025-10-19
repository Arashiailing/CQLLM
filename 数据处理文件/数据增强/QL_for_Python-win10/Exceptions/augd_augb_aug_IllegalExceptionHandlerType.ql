/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types,
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

// Detect ineffective exception handlers that reference non-exception types
from ExceptFlowNode exceptHandler, Value caughtType, ClassValue exceptionCls, 
     ControlFlowNode exceptionOrigin, string typeDescription
where
  // Establish the relationship between the exception handler and its handled type
  exceptHandler.handledException(caughtType, exceptionCls, exceptionOrigin) and
  (
    // First case: The type is a class but not a valid exception class
    exists(ClassValue invalidExcClass | 
      invalidExcClass = caughtType and
      not invalidExcClass.isLegalExceptionType() and
      not invalidExcClass.failedInference(_) and
      typeDescription = "class '" + invalidExcClass.getName() + "'"
    )
    or
    // Second case: The type is not a class at all
    not caughtType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionCls.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, typeDescription