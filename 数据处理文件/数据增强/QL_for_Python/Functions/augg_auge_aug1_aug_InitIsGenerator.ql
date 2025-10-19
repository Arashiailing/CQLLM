/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers that contain generator expressions (yield/yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initializer
where
  // Verify the target is a class initialization method
  initializer.isInitMethod() and
  (
    // Detect presence of yield statements within method body
    exists(Yield yieldNode | yieldNode.getScope() = initializer) or
    // Detect presence of yield from statements within method body
    exists(YieldFrom yieldFromNode | yieldFromNode.getScope() = initializer)
  )
select initializer, "__init__ method is a generator."