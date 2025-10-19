/**
 * @name Generator in `__init__` method
 * @description Identifies class initializers containing generator expressions (yield/yield from).
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
  // Verify the function is a class initializer
  initializer.isInitMethod() and
  // Check for generator expressions within the method scope
  exists(Expr genExpr | 
    (genExpr instanceof Yield or genExpr instanceof YieldFrom) and
    genExpr.getScope() = initializer
  )
select initializer, "__init__ method is a generator."