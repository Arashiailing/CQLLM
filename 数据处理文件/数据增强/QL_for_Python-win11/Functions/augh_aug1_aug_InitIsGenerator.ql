/**
 * @name Generator in `__init__` method
 * @description Detects class initializers that contain generator expressions using yield or yield from.
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
  // Confirm the function is a class initializer
  initMethod.isInitMethod()
  // Check for generator expressions within the method body
  and (
    // Look for any yield statements in the method scope
    exists(Yield yieldStmt | yieldStmt.getScope() = initMethod)
    or
    // Look for any yield from statements in the method scope
    exists(YieldFrom yieldFromStmt | yieldFromStmt.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."