/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers using non-exception types that will never catch exceptions.
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

from ExceptFlowNode exceptionNode, Value exceptionType, ClassValue exceptionClass, 
     ControlFlowNode originNode, string description
where
  // Identify exception handling relationships
  exceptionNode.handledException(exceptionType, exceptionClass, originNode) and
  (
    // Case 1: Explicit class that isn't a valid exception type
    exists(ClassValue invalidClass | invalidClass = exceptionType |
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      description = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: Non-class type used in exception handler
    not exceptionType instanceof ClassValue and
    description = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  originNode, description