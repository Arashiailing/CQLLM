/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that reference non-exception types,
 *              rendering them ineffective as they cannot catch actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Analyze exception handling constructs to find ineffective handlers
from ExceptFlowNode exceptHandler, Value caughtType, ClassValue typeBase, 
     ControlFlowNode sourceNode, string typeInfo
where
  // Ensure the handler processes a specific exception type from the source
  exceptHandler.handledException(caughtType, typeBase, sourceNode) and
  (
    // Scenario 1: The type is a class but not a valid exception
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = caughtType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      typeInfo = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Scenario 2: The type is not a class value
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + typeBase.getName() + "'"
  )
select exceptHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeInfo