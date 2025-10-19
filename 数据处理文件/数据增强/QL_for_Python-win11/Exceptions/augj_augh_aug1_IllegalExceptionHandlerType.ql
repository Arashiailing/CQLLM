/**
 * @name Non-exception in 'except' clause
 * @description Detects exception handlers specifying non-exception types that will never catch exceptions.
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

// Identify non-exception types in exception handlers
from ExceptFlowNode exceptionHandler, Value exceptionType, ClassValue exceptionClass, 
     ControlFlowNode sourceNode, string errorDescription
where
  // Analyze handled exception types
  exceptionHandler.handledException(exceptionType, exceptionClass, sourceNode) and
  (
    // Case 1: Type is a class but not a valid exception class
    exists(ClassValue illegalClass | 
      illegalClass = exceptionType and
      not illegalClass.isLegalExceptionType() and
      not illegalClass.failedInference(_) and
      errorDescription = "class '" + illegalClass.getName() + "'"
    )
    or
    // Case 2: Type is a class instance instead of a class
    not exceptionType instanceof ClassValue and
    errorDescription = "instance of '" + exceptionClass.getName() + "'"
  )
select exceptionHandler.getNode(),
  "Non-exception $@ in exception handler which will never match raised exception.", 
  sourceNode, errorDescription