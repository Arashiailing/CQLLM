/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers specifying non-exception types that will never catch any exception.
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

from ExceptFlowNode exceptNode, Value handledType, ClassValue classValue, ControlFlowNode sourceNode, string description
where
  // Identify exception handling relationships
  exceptNode.handledException(handledType, classValue, sourceNode) and
  (
    // Case 1: Handler uses a class that isn't a valid exception type
    exists(ClassValue invalidClass | invalidClass = handledType |
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      description = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Handler uses a non-class type
    not handledType instanceof ClassValue and
    description = "instance of '" + classValue.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", sourceNode, description