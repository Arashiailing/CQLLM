/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types which will never match raised exceptions.
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

// Identify exception handlers with invalid exception types
from ExceptFlowNode exceptFlowNode, Value handledType, ClassValue handledClass, 
     ControlFlowNode originNode, string description
where
  // Verify the exception node handles a specific exception type
  exceptFlowNode.handledException(handledType, handledClass, originNode) and
  (
    // Case 1: Exception type is a class but not a valid exception class
    handledType instanceof ClassValue and
    not handledType.(ClassValue).isLegalExceptionType() and
    not handledType.(ClassValue).failedInference(_) and
    description = "class '" + handledType.(ClassValue).getName() + "'"
    or
    // Case 2: Exception type is an instance instead of a class
    not (handledType instanceof ClassValue) and
    description = "instance of '" + handledClass.getName() + "'"
  )
select exceptFlowNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, description