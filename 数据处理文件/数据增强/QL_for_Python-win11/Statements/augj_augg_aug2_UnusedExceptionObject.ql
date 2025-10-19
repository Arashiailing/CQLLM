/**
 * @name Unused exception object
 * @description Detects exception instances that are created but never utilized (e.g., not raised).
 * @kind problem
 * @tags reliability
 *       maintainability
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/unused-exception-object
 */

import python  // Import Python library for code analysis

// Query to identify unused exception instantiations
from Call exceptionCall, ClassValue exnClass
where
  // Verify the class is an exception type (inherits from base Exception)
  exnClass.getASuperType() = ClassValue::exception() and
  // Ensure the call instantiates this exception class
  exceptionCall.getFunc().pointsTo(exnClass) and
  // Confirm the instantiation is only used as a standalone statement (not raised)
  exists(ExprStmt standaloneStmt | standaloneStmt.getValue() = exceptionCall)
select exceptionCall, "Instantiating an exception, but not raising it, has no effect."