/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers that utilize generator expressions (yield or yield from).
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
  // Verify the function is a class initialization method
  classInitializer.isInitMethod() and
  // Check if the method contains any generator expressions
  (
    // Check for 'yield' expressions within the method
    exists(Yield generatorYield | generatorYield.getScope() = classInitializer) or
    // Check for 'yield from' expressions within the method
    exists(YieldFrom generatorYieldFrom | generatorYieldFrom.getScope() = classInitializer)
  )
select classInitializer, "__init__ method is a generator."