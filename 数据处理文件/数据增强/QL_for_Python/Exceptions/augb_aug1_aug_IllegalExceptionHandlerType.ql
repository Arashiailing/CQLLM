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
from ExceptFlowNode handlerNode, Value caughtType, ClassValue exceptionType, 
     ControlFlowNode sourceNode, string typeMsg
where
  // Establish relationship between handler and caught exception type
  handlerNode.handledException(caughtType, exceptionType, sourceNode) and
  (
    // Case 1: Caught type is a class but not a valid exception
    exists(ClassValue invalidClass | 
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeMsg = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Caught type is not a class value
    not caughtType instanceof ClassValue and
    typeMsg = "instance of '" + exceptionType.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeMsg