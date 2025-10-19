/**
 * @name `__init__` method is a generator
 * @description Detects `__init__` methods that are generators. In Python, `__init__` methods should not be generators as they initialize object instances.
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initFunc
where
  // Verify the function is a class initializer (__init__ method)
  initFunc.isInitMethod() and
  // Check for generator-indicating statements (yield/yield from) within the method scope
  exists(AstNode generatorNode |
    (generatorNode instanceof Yield or generatorNode instanceof YieldFrom) and
    generatorNode.getScope() = initFunc
  )
select initFunc, "__init__ method is a generator."