/**
 * @name Generator in `__init__` method
 * @description Identifies class initialization methods that contain generator expressions (yield/yield from).
 *              This is considered a reliability issue as __init__ methods should not be generators.
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
  // First condition: must be a class initializer
  initializerMethod.isInitMethod()
  // Second condition: must contain generator expressions
  and (
    exists(Yield generatorYield | generatorYield.getScope() = initializerMethod) or
    exists(YieldFrom generatorYieldFrom | generatorYieldFrom.getScope() = initializerMethod)
  )
select initializerMethod, "__init__ method is a generator."