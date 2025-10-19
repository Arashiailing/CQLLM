/**
 * @name Unused exception object
 * @description Identifies exception instances that are created but never used (e.g., raised or handled).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Find exception instances that are created but never utilized
from Call unusedExceptionInstance, ClassValue exceptionClass
where
  // Ensure the call is to an exception class that inherits from base Exception
  unusedExceptionInstance.getFunc().pointsTo(exceptionClass) and
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Check if the instantiation is in an unused expression statement
  exists(ExprStmt exprStatement | 
    exprStatement.getValue() = unusedExceptionInstance
  )
select unusedExceptionInstance, "Instantiating an exception, but not raising it, has no effect."