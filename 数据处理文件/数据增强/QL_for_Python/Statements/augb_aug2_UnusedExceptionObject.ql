/**
 * @name Unused exception object
 * @description Identifies exception objects that are instantiated but never utilized (e.g., raised or handled).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Identify unused exception instantiations
from Call unusedExceptionInstantiation, ClassValue exceptionClass
where
  // Verify the call targets an exception class
  unusedExceptionInstantiation.getFunc().pointsTo(exceptionClass) and
  // Ensure the exception class inherits from base Exception
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Confirm the exception is instantiated but never used (e.g., raised)
  exists(ExprStmt unusedExprStatement | 
    unusedExprStatement.getValue() = unusedExceptionInstantiation
  )
select unusedExceptionInstantiation, "Instantiating an exception, but not raising it, has no effect."