/**
 * @name Unused exception object
 * @description Detects when an exception object is created but never used,
 *              which typically indicates a programming error or incomplete code.
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python analysis library for code inspection capabilities

// Identify locations where exception objects are instantiated but not utilized
from Call unusedExceptionInstance, ClassValue exceptionClass
where
  // Verify that the call targets an exception class
  unusedExceptionInstance.getFunc().pointsTo(exceptionClass) and
  // Ensure the class inherits from Python's base exception class
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Check that the exception object exists only as a standalone expression statement
  exists(ExprStmt standaloneExpression | 
    standaloneExpression.getValue() = unusedExceptionInstance
  )
select unusedExceptionInstance, "Instantiating an exception, but not raising it, has no effect."