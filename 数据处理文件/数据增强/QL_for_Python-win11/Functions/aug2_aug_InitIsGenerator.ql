/**
 * @name Generator in `__init__` method
 * @description Identifies when a class's initializer contains generator expressions (yield or yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initializationMethod
where
  // Verify that the function is a class initializer
  initializationMethod.isInitMethod() and
  // Check for the presence of any generator expressions (yield or yield from) within the method body
  exists(Expr generatorExpr | 
    generatorExpr.getScope() = initializationMethod and
    (generatorExpr instanceof Yield or generatorExpr instanceof YieldFrom))
select initializationMethod, "__init__ method is a generator."