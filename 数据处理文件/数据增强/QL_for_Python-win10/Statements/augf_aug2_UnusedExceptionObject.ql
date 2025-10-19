/**
 * @name Unused exception object
 * @description Identifies exception objects that are instantiated but never utilized (e.g., raised).
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
from Call exceptionInstantiation, ClassValue exceptionClass
where
  // Verify the call targets an exception class
  exceptionInstantiation.getFunc().pointsTo(exceptionClass) and
  // Ensure the exception class inherits from base Exception
  exceptionClass.getASuperType() = ClassValue::exception() and
  // Confirm the instantiation is unused (standalone statement)
  exists(ExprStmt standaloneStatement | 
    standaloneStatement.getValue() = exceptionInstantiation
  )
select exceptionInstantiation, "Exception instantiated but never raised - this has no effect."