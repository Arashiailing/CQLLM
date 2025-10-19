/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types, which will never catch any raised exceptions.
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

// Identify problematic exception handlers with non-exception types
from ExceptFlowNode exceptNode, Value handledType, ClassValue exceptionClass, ControlFlowNode sourceNode, string typeDescription
where
  // Ensure the exception node processes a specific type from a source
  exceptNode.handledException(handledType, exceptionClass, sourceNode) and
  (
    // Case 1: Type is a class that isn't a valid exception type
    exists(ClassValue invalidClass | invalidClass = handledType |
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Type is an instance rather than a class
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
// Report the problematic exception handler with contextual details
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", sourceNode, typeDescription