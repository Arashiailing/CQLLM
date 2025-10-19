/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that specify non-exception types,
 *              which will never catch any raised exception.
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
from ExceptFlowNode handlerNode, Value handledType, ClassValue baseClass, 
     ControlFlowNode sourceNode, string typeDescriptor
where
  // Retrieve exception handling details
  handlerNode.handledException(handledType, baseClass, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception class
    exists(ClassValue invalidClass | 
      invalidClass = handledType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescriptor = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Type is an instance instead of a class
    not handledType instanceof ClassValue and
    typeDescriptor = "instance of '" + baseClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, typeDescriptor