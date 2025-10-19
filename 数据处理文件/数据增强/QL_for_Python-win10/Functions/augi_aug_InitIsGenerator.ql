/**
 * @name Generator in `__init__` method
 * @description Identifies when a class's initialization method contains generator expressions (yield or yield from).
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
  // Verify that the function is a class initializer
  initializerMethod.isInitMethod() and
  // Check if the method body contains any generator expressions
  exists(Expr generatorExpr | 
    (generatorExpr instanceof Yield or generatorExpr instanceof YieldFrom) and
    generatorExpr.getScope() = initializerMethod)
select initializerMethod, "__init__ method is a generator."