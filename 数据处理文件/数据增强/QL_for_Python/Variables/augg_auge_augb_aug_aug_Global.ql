/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables that are accessed or modified
 *              outside of the module scope. This practice can lead to
 *              unintended side effects and violates encapsulation,
 *              making code more difficult to maintain and debug.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables used in non-module contexts
from Global globalVarInNonModule
where 
  // Check if variable's scope is not at module level
  exists(Scope varScope | 
    varScope = globalVarInNonModule.getScope() and
    not varScope instanceof Module
  )
select 
  globalVarInNonModule, 
  "Updating global variables except at module initialization is discouraged."