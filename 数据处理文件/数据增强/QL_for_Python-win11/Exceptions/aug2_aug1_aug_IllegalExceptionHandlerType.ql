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

// Variables for analyzing exception handling constructs
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionBase, 
     ControlFlowNode sourceNode, string typeInfo
where
  // Verify the handler processes a specific exception type from the source
  exceptNode.handledException(caughtType, exceptionBase, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue invalidType | 
      invalidType = caughtType and
      not invalidType.isLegalExceptionType() and
      not invalidType.failedInference(_) and
      typeInfo = "class '" + invalidType.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not caughtType instanceof ClassValue and
    typeInfo = "instance of '" + exceptionBase.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeInfo