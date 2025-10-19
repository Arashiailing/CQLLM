/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers that utilize non-exception types,
 *              rendering them ineffective as they cannot catch actual exceptions.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/useless-except
 */

import python

// Variables for analyzing exception handling constructs
from ExceptFlowNode handlerNode, Value handledType, ClassValue baseException, 
     ControlFlowNode originNode, string typeDescription
where
  // Verify the handler processes a specific exception type from the source
  handlerNode.handledException(handledType, baseException, originNode) and
  (
    // Case 1: Type is a class but not a valid exception
    exists(ClassValue invalidType | 
      invalidType = handledType and
      not invalidType.isLegalExceptionType() and
      not invalidType.failedInference(_) and
      typeDescription = "class '" + invalidType.getName() + "'"
    )
    or
    // Case 2: Type is not a class value
    not handledType instanceof ClassValue and
    typeDescription = "instance of '" + baseException.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescription