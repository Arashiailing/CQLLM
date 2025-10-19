/**
 * @name Generator in `__init__` method
 * @description Detects class initializers containing generator expressions (yield/yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initMethod
where
  // Confirm target is a class initialization method
  initMethod.isInitMethod() and
  (
    // Check for yield statements within method body
    exists(Yield yieldStmt | yieldStmt.getScope() = initMethod) or
    // Check for yield from statements within method body
    exists(YieldFrom yieldFromStmt | yieldFromStmt.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."