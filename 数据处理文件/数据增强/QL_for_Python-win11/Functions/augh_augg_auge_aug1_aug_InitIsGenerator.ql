/**
 * @name Generator in `__init__` method
 * @description Detects class initializers that implement generator functionality using yield expressions.
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
  // Confirm that the function is a class initializer (__init__ method)
  initMethod.isInitMethod() and
  (
    // Check for the existence of yield expressions within the method's scope
    exists(Yield yieldExpr | yieldExpr.getScope() = initMethod) or
    // Check for the existence of yield from expressions within the method's scope
    exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = initMethod)
  )
select initMethod, "__init__ method is a generator."