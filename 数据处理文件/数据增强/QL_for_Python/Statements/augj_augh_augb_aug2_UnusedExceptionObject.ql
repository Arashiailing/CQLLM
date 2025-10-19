/**
 * @name Unused exception object
 * @description Detects exception instances that are created but never utilized (e.g., raised or handled).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Identify exception instantiations that are created but never used
from Call exceptionInstantiation, ClassValue exceptionClass
where
  // Verify the call targets an exception class
  exceptionInstantiation.getFunc().pointsTo(exceptionClass) and
  // Ensure the class inherits from the base Exception class
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Confirm the exception is created as a standalone expression without usage
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionInstantiation
  )
select exceptionInstantiation, "Instantiating an exception without raising or handling it has no effect."