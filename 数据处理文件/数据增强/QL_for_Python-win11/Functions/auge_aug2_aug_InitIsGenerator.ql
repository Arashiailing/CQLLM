/**
 * @name Generator expression in class initializer
 * @description Detects class initializers (__init__ methods) that contain generator expressions (yield or yield from).
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
  // Check for the presence of any generator expressions (yield or yield from) within the method body
  exists(Expr yieldExpr | 
    yieldExpr.getScope() = initMethod and
    (yieldExpr instanceof Yield or yieldExpr instanceof YieldFrom)) and
  // Verify that the function is a class initializer
  initMethod.isInitMethod()
select initMethod, "__init__ method is a generator."