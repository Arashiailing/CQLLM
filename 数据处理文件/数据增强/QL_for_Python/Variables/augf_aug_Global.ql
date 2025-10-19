/**
 * @name Non-module global variable usage
 * @description Detects global variables declared outside of module scope.
 *              Such usage can lead to code that is difficult to maintain and test,
 *              as it breaks encapsulation principles and creates hidden dependencies.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify all global variable declarations that exist outside module scope
from Global nonModuleGlobalVar
// Apply filter to exclude globals that are properly defined at module level
where not (nonModuleGlobalVar.getScope() instanceof Module)
// Return the violating global variable with an appropriate warning message
select nonModuleGlobalVar, "Updating global variables except at module initialization is discouraged."