/**
 * @name Generator in `__init__` method
 * @description Identifies when a class initialization method contains generator expressions (yield or yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initializerMethod
where
  // Verify that this is a class initialization method
  initializerMethod.isInitMethod() and
  // Check for presence of generator statements in the method body
  (
    exists(Yield yieldStatement | yieldStatement.getScope() = initializerMethod) or
    exists(YieldFrom yieldFromStatement | yieldFromStatement.getScope() = initializerMethod)
  )
select initializerMethod, "__init__ method is a generator."