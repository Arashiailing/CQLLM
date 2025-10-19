/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers that utilize generator expressions (yield or yield from),
 *              which may cause unexpected behavior as __init__ methods should return None.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function classInitializer
where
  // Verify that we're analyzing a class initialization method
  classInitializer.isInitMethod() and
  // Check if the method contains any generator expressions
  (
    exists(Yield yieldExpr | yieldExpr.getScope() = classInitializer) or
    exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = classInitializer)
  )
select classInitializer, "__init__ method is a generator."