/**
 * @name Unused exception object
 * @description Detects when an exception object is instantiated but never utilized.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python module for code analysis

// Query to identify exception objects that are created but not used
from Call exceptionCall, ClassValue exceptionClass
where
  // Verify that the called function targets an exception class
  exceptionCall.getFunc().pointsTo(exceptionClass) and
  // Ensure the class is a subclass of the base Exception class
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Confirm the call exists as a standalone expression statement
  exists(ExprStmt statement | statement.getValue() = exceptionCall)
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."  // Output matching calls with descriptive message