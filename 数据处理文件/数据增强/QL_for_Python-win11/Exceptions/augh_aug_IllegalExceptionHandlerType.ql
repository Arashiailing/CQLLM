/**
 * @name Non-exception in 'except' clause
 * @description Detects when an exception handler catches a non-exception type,
 *              which will never match any raised exception at runtime.
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
from ExceptFlowNode handlerNode, Value handledType, ClassValue typeClass, 
     ControlFlowNode sourceNode, string issueDesc
where
  // Analyze exception handling relationships
  handlerNode.handledException(handledType, typeClass, sourceNode) and
  (
    // Case 1: Exception type is a class but not a valid exception
    exists(ClassValue invalidClass | 
      invalidClass = handledType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      issueDesc = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Exception type is not a class at all
    not handledType instanceof ClassValue and
    issueDesc = "instance of '" + typeClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, issueDesc