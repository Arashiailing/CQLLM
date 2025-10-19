/**
 * @name Generator in `__init__` method
 * @description Detects class initializers that contain generator expressions (yield or yield from),
 *              which can lead to unexpected behavior since __init__ methods are expected to return None.
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
  // Ensure we're examining a class initialization method
  initMethod.isInitMethod() and
  // Check for presence of generator expressions in the method body
  (
    exists(Yield yieldStmt | yieldStmt.getScope() = initMethod) or
    exists(YieldFrom yieldFromStmt | yieldFromStmt.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."