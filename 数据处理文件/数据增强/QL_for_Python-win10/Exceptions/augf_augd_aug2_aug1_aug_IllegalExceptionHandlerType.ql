/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that use non-exception types,
 *              which are ineffective as they never match actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Core variables for exception handler analysis
from ExceptFlowNode handlerNode, Value caughtType, ClassValue baseEx, 
     ControlFlowNode exceptionSource, string typeDesc
where
  // Ensure handler processes a specific exception type from source
  handlerNode.handledException(caughtType, baseEx, exceptionSource) and
  (
    // Case 1: Invalid exception class type
    exists(ClassValue invalidExClass | 
      invalidExClass = caughtType and
      not invalidExClass.isLegalExceptionType() and
      not invalidExClass.failedInference(_) and
      typeDesc = "class '" + invalidExClass.getName() + "'"
    )
    or
    // Case 2: Non-class exception type
    not caughtType instanceof ClassValue and
    typeDesc = "instance of '" + baseEx.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionSource, typeDesc