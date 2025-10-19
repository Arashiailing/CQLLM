/**
 * @name Non-exception type in exception handler
 * @description Identifies exception handlers that use non-exception types,
 *              making them ineffective at catching runtime exceptions.
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

// Define variables for analyzing exception handling constructs
from ExceptFlowNode handlerNode, Value handledType, ClassValue typeClass, 
     ControlFlowNode sourceNode, string typeDescription
where
  // Verify that the exception handler processes a specific exception type from the source
  handlerNode.handledException(handledType, typeClass, sourceNode) and
  (
    // Case 1: The handled type is a class but not a valid exception class
    exists(ClassValue invalidClass | 
      invalidClass = handledType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: The handled type is not a class at all
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + typeClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDescription