/**
 * @name Generator expression in class initializer
 * @description Identifies class initializers (__init__ methods) containing generator expressions (yield/yield from).
 * @kind problem
 * @tags reliability
 *       correctness
 * @problem.severity error
 * @sub-severity low
 * @precision very-high
 * @id py/init-method-is-generator
 */

import python

from Function classInitializer
where
  // Ensure the function is a class initializer
  classInitializer.isInitMethod() and
  // Check for generator expressions within the method body
  exists(Expr generatorExpr | 
    generatorExpr.getScope() = classInitializer and
    (generatorExpr instanceof Yield or generatorExpr instanceof YieldFrom))
select classInitializer, "__init__ method is a generator."