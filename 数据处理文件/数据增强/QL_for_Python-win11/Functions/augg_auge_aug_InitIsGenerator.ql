/**
 * @name Generator in `__init__` method
 * @description Detects and reports generator usage (yield/yield from) within class initialization methods.
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
  // Identify class initialization methods
  initMethod.isInitMethod() and
  // Check for generator expressions within the method scope
  exists(Expr yieldExpr | 
    yieldExpr.getScope() = initMethod and
    (yieldExpr instanceof Yield or yieldExpr instanceof YieldFrom))
select initMethod, "__init__ method is a generator."