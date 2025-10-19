/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers containing generator expressions (yield/yield from).
 *              Such usage violates the expectation that __init__ should return None,
 *              potentially causing runtime errors and unexpected behavior.
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
  // Target class initialization methods specifically
  initializerMethod.isInitMethod() and
  // Detect presence of generator expressions within method body
  exists(Expr generatorExpr | 
    generatorExpr.getScope() = initializerMethod and
    (
      generatorExpr instanceof Yield or
      generatorExpr instanceof YieldFrom
    )
  )
select initializerMethod, "__init__ method is a generator."