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

// Analyze exception handling constructs for invalid exception types
from ExceptFlowNode exceptHandler, Value caughtType, ClassValue raisedClass, 
     ControlFlowNode raiseLocation, string typeDesc
where
  // Verify the handler processes a specific exception type from the source
  exceptHandler.handledException(caughtType, raisedClass, raiseLocation) and
  (
    // Case 1: Exception type is a class but not a valid exception class
    exists(ClassValue invalidClass | 
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDesc = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class at all
    not caughtType instanceof ClassValue and
    typeDesc = "instance of '" + raisedClass.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  raiseLocation, typeDesc