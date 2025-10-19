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

// Locate global variables used in non-module contexts
from Global nonModuleGlobalVar
where 
  // Verify the variable's scope is not at module level
  not nonModuleGlobalVar.getScope() instanceof Module
select 
  nonModuleGlobalVar, 
  "Updating global variables except at module initialization is discouraged."