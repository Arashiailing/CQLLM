/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types,
 *              which will never match any raised exception.
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
from ExceptFlowNode handlerNode, Value handledType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string typeDescription
where
  // Establish relationship between handler, exception type, and source
  handlerNode.handledException(handledType, exceptionClass, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception type
    exists(ClassValue invalidClass | 
      invalidClass = handledType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Type is not a class at all
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDescription