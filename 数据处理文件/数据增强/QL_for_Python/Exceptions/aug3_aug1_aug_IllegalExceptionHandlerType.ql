/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types,
 *              which are ineffective at runtime as they never match actual exceptions.
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

// Core variables for exception handler analysis
from ExceptFlowNode handlerNode, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string typeDesc
where
  // Establish relationship between handler and exception source
  handlerNode.handledException(caughtType, exceptionClass, sourceNode) and
  (
    // Check for non-exception class type
    exists(ClassValue invalidType | 
      invalidType = caughtType and
      not invalidType.isLegalExceptionType() and
      not invalidType.failedInference(_) and
      typeDesc = "class '" + invalidType.getName() + "'"
    )
    or
    // Handle non-class value cases
    not caughtType instanceof ClassValue and
    typeDesc = "instance of '" + exceptionClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDesc