/**
 * @name Invalid Exception Type in 'except' Clause
 * @description Identifies exception handlers using non-exception types,
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
from ExceptFlowNode handlerNode, Value capturedType, ClassValue exceptionClass, 
     ControlFlowNode originNode, string typeDescriptor
where
  // Establish relationship between exception handler and its processed exception
  handlerNode.handledException(capturedType, exceptionClass, originNode) and
  (
    // Case 1: The captured type is a class but not a valid exception type
    exists(ClassValue invalidClass | 
      invalidClass = capturedType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescriptor = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: The captured type is not a class at all
    not capturedType instanceof ClassValue and
    typeDescriptor = "instance of '" + exceptionClass.getName() + "'"
  )
select handlerNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, typeDescriptor