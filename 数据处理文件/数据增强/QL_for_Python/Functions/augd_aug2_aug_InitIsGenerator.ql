/**
 * @name Generator in `__init__` method
 * @description Detects when a class initializer contains generator expressions (yield or yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function initMethod
where
  // Confirm the function is a class initializer
  initMethod.isInitMethod() and
  // Identify generator expressions within the method's scope
  exists(Expr genExpr | 
    (genExpr instanceof Yield or genExpr instanceof YieldFrom) and
    genExpr.getScope() = initMethod)
select initMethod, "__init__ method is a generator."