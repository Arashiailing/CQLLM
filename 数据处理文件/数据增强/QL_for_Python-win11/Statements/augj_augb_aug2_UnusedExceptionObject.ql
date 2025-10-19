/**
 * @name Unused exception object
 * @description Detects exception instances that are created but never utilized (such as being raised or handled).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Identify exception creation calls that are never used
from Call exceptionCreationCall, ClassValue targetExceptionClass
where
  // Check if the call is targeting an exception class constructor
  exceptionCreationCall.getFunc().pointsTo(targetExceptionClass) and
  // Verify the class is derived from the base Exception class
  targetExceptionClass.getASuperType() = ClassValue::exception() and
  // Confirm the exception instance is created but never used (e.g., not raised)
  exists(ExprStmt standaloneExpressionStmt | 
    standaloneExpressionStmt.getValue() = exceptionCreationCall
  )
select exceptionCreationCall, "Instantiating an exception, but not raising it, has no effect."