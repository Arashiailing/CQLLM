/**
 * @name Non-exception in 'except' clause
 * @description Identifies exception handlers that specify non-exception types.
 *              These handlers are ineffective at runtime because they cannot catch
 *              any actual exceptions that might be raised.
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

// Variables for analyzing exception handlers and their types
from ExceptFlowNode handlerNode, Value caughtType, ClassValue actualType, 
     ControlFlowNode sourceNode, string typeMessage
where
  // Associate exception handler with its caught type and source
  handlerNode.handledException(caughtType, actualType, sourceNode) and
  (
    // Case 1: Caught type is a class but not a valid exception
    exists(ClassValue invalidClass | 
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeMessage = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Caught type is not a class value
    not caughtType instanceof ClassValue and
    typeMessage = "instance of '" + actualType.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeMessage