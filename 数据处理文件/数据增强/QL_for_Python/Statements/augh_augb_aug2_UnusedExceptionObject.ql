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

// Find exception instantiations that are created but never used
from Call exceptionCall, ClassValue targetExceptionClass
where
  // The call must target an exception class
  exceptionCall.getFunc().pointsTo(targetExceptionClass) and
  // The class must inherit from the base Exception class
  targetExceptionClass.getASuperType() = ClassValue::exception() and
  // The exception is instantiated but never used (just created as a standalone expression)
  exists(ExprStmt statement | 
    statement.getValue() = exceptionCall
  )
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."