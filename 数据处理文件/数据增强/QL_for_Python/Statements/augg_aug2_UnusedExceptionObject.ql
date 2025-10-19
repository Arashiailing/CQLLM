/**
 * @name Unused exception object
 * @description Identifies exception objects that are created but never utilized (e.g., not raised).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Query to detect exception instantiations that are not used
from Call exceptionInstantiation, ClassValue exceptionClass
where
  // Ensure the call is instantiating an exception class
  exceptionInstantiation.getFunc().pointsTo(exceptionClass) and
  // Verify the exception class inherits from base Exception
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Check that the exception instantiation is only used as a statement (not raised)
  exists(ExprStmt expressionStatement | expressionStatement.getValue() = exceptionInstantiation)
select exceptionInstantiation, "Instantiating an exception, but not raising it, has no effect."