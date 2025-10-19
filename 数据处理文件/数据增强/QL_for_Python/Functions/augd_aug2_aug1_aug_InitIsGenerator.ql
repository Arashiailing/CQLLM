/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers that include generator expressions (yield or yield from),
 *              which can cause unexpected behavior as __init__ methods should return None.
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
  // Determine if the method body contains generator expressions
  (
    exists(Yield generatorExpr | generatorExpr.getScope() = classInitializer) or
    exists(YieldFrom yieldFromExpr | yieldFromExpr.getScope() = classInitializer)
  )
select classInitializer, "__init__ method is a generator."