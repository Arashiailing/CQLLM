/**
 * @name Generator in `__init__` method
 * @description Identifies when a class initializer contains generator expressions (yield or yield from).
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
  // Verify this is a class initialization method
  initializer.isInitMethod() and
  (
    // Check if method body contains yield statements
    exists(Yield yieldNode | yieldNode.getScope() = initializer) or
    // Check if method body contains yield from statements
    exists(YieldFrom yieldFromNode | yieldFromNode.getScope() = initializer)
  )
select initializer, "__init__ method is a generator."