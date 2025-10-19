/**
 * @name Unused exception object
 * @description Detects exception objects that are instantiated but never used (e.g., raised).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Define the query to find unused exception objects
from Call unusedExceptionCall, ClassValue exceptionType
where
  // The call must target an exception class
  unusedExceptionCall.getFunc().pointsTo(exceptionType) and
  // The exception type must inherit from the base Exception class
  exceptionType.getASuperType() = ClassValue::exception() and
  // The exception must be instantiated but not used (e.g., raised)
  exists(ExprStmt exprStatement | exprStatement.getValue() = unusedExceptionCall)
select unusedExceptionCall, "Instantiating an exception, but not raising it, has no effect."