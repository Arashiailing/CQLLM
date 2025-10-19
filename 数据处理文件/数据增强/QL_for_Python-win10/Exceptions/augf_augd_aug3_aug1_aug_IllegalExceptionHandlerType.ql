/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handling blocks that reference non-exception types,
 *              rendering them ineffective as they cannot catch actual exceptions at runtime.
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

// Core variables for analyzing exception handling constructs
from ExceptFlowNode exceptionBlock, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode exceptionOrigin, string typeInfo
where
  // Establish connection between exception handler and its source
  exceptionBlock.handledException(caughtType, exceptionClass, exceptionOrigin)
  and
  (
    // Case 1: Handler uses a class that is not a valid exception type
    exists(ClassValue invalidException | 
      invalidException = caughtType and
      not invalidException.isLegalExceptionType() and
      not invalidException.failedInference(_) and
      typeInfo = "class '" + invalidException.getName() + "'"
    )
    or
    // Case 2: Handler uses a non-class value (instance instead of class)
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionBlock.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, typeInfo