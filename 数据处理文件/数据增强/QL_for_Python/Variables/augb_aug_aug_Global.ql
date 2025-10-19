/**
 * @name Use of the 'global' statement.
 * @description Detects global variables declared outside module scope.
 *              This practice violates encapsulation principles, making code
 *              harder to maintain and debug.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables declared outside module scope
from Global globalVarNotInModule
where 
  // Ensure variable's scope is not module-level
  not (globalVarNotInModule.getScope() instanceof Module)
select 
  globalVarNotInModule, 
  "Updating global variables except at module initialization is discouraged."