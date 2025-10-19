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

// Identify unused exception instantiations
from Call unusedExnCall, ClassValue exnClass
where
  // Verify call targets an exception class inheriting from base Exception
  unusedExnCall.getFunc().pointsTo(exnClass) and
  exnClass.getASuperType() = ClassValue::exception() and
  // Confirm instantiation appears in unused expression statement
  exists(ExprStmt stmt | 
    stmt.getValue() = unusedExnCall
  )
select unusedExnCall, "Instantiating an exception, but not raising it, has no effect."