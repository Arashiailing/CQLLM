/**
 * @name Invalid Exception Type in 'except' Clause
 * @description Identifies exception handlers that reference non-exception types,
 *              making them ineffective since they cannot catch any runtime exceptions.
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
from ExceptFlowNode exceptionHandler, Value exceptionType, ClassValue exceptionClass, 
     ControlFlowNode exceptionOrigin, string exceptionDescription
where
  // Establish relationship between exception handler and the exception it processes
  exceptionHandler.handledException(exceptionType, exceptionClass, exceptionOrigin) and
  (
    // Case 1: The captured type is a class but not a valid exception type
    exists(ClassValue invalidExceptionClass | 
      invalidExceptionClass = exceptionType and
      not invalidExceptionClass.isLegalExceptionType() and
      not invalidExceptionClass.failedInference(_) and
      exceptionDescription = "class '" + invalidExceptionClass.getName() + "'"
    )
    or
    // Case 2: The captured type is not a class at all
    not exceptionType instanceof ClassValue and
    exceptionDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  exceptionOrigin, exceptionDescription