/**
 * @name Unused exception object
 * @description Detects exception objects that are instantiated but never utilized (e.g., raised or handled).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Identify exception instances that are created but never utilized
from Call unutilizedExnInstance, ClassValue exceptionType
where
  // Check if the call is to an exception class that inherits from base Exception
  unutilizedExnInstance.getFunc().pointsTo(exceptionType) and
  exceptionType.getASuperType() = ClassValue::exception() and
  // Verify the instantiation is in an unused expression statement
  exists(ExprStmt expressionStatement | 
    expressionStatement.getValue() = unutilizedExnInstance
  )
select unutilizedExnInstance, "Instantiating an exception, but not raising it, has no effect."