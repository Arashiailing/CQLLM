/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables used outside of module scope.
 *              Such usage can lead to code that is difficult to maintain and debug,
 *              as it violates the principle of encapsulation.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables that are declared outside of module scope
from Global nonModuleGlobalVar
// Filter condition: ensure that the global variable's scope is not at module level
where not (nonModuleGlobalVar.getScope() instanceof Module)
// Return results: global variable instance and associated warning message
select nonModuleGlobalVar, "Updating global variables except at module initialization is discouraged."