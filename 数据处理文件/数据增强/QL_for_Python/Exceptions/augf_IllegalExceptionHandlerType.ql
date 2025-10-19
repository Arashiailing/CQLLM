/**
 * @name Non-exception in 'except' clause
 * @description An exception handler specifying a non-exception type will never handle any exception.
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

// Select exception handling nodes with invalid exception types
from ExceptFlowNode exceptNode, Value handledType, ClassValue exceptionClass, ControlFlowNode sourceNode, string description
where
  // Identify handled exception and its origin
  exceptNode.handledException(handledType, exceptionClass, sourceNode) and
  (
    // Case 1: Handled type is a class that isn't a valid exception
    exists(ClassValue invalidClass | invalidClass = handledType |
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      description = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Handled type is an instance (not a class)
    not handledType instanceof ClassValue and
    description = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", sourceNode, description