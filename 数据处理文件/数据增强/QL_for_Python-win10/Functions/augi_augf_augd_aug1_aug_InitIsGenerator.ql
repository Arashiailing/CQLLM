/**
 * @name Generator in `__init__` method
 * @description Detects class initializers containing generator expressions (yield/yield from)
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
  initMethod.isInitMethod() and
  // Verify presence of generator expressions in the method
  (
    // Check for 'yield' expressions
    exists(Yield yieldExpr | yieldExpr.getScope() = initMethod) or
    // Check for 'yield from' expressions
    exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."