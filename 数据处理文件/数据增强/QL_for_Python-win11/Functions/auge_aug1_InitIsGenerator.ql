/**
 * @name `__init__` method is a generator
 * @description Identifies `__init__` methods that behave as generators. In Python, `__init__` methods 
 *              should not be generators as they are responsible for object initialization.
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
  // Verify that the function is a class initializer method (i.e., __init__ method)
  initializerMethod.isInitMethod() and
  (
    // Check if the function body contains yield statements, indicating it's a generator
    exists(Yield yieldStmt | yieldStmt.getScope() = initializerMethod) or
    // Check if the function body contains yield from statements, also indicating it's a generator
    exists(YieldFrom yieldFromStmt | yieldFromStmt.getScope() = initializerMethod)
  )
select initializerMethod, "__init__ method is a generator."