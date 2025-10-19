/**
 * @name Invalid Exception Type in 'except' Clause
 * @description Detects exception handlers that use non-exception types,
 *              rendering them ineffective as they cannot catch any runtime exceptions.
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
from ExceptFlowNode exceptNode, Value caughtType, ClassValue exceptionClass, 
     ControlFlowNode typeOrigin, string typeDescription
where
  // Establish relationship between exception handler and the exception it processes
  exceptNode.handledException(caughtType, exceptionClass, typeOrigin) and
  (
    // Case 1: The caught type is a class but not a valid exception type
    exists(ClassValue invalidClass | 
      invalidClass = caughtType and
      not invalidClass.isLegalExceptionType() and
      not invalidClass.failedInference(_) and
      typeDescription = "class '" + invalidClass.getName() + "'"
    )
    or
    // Case 2: The caught type is not a class at all
    not caughtType instanceof ClassValue and
    typeDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptNode.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  typeOrigin, typeDescription