/**
 * @name Use of the 'global' statement.
 * @description Detects global variables that are used or modified outside of module scope.
 *              This practice can make code harder to maintain and debug, as it breaks encapsulation
 *              by allowing variables to be modified from anywhere in the codebase.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find all global variables that are declared or used outside of module scope
from Global globalVarOutsideModule
// Ensure the global variable is not at the module level (i.e., it's inside a function or class)
where not (globalVarOutsideModule.getScope() instanceof Module)
// Report the global variable with a warning message
select globalVarOutsideModule, "Updating global variables except at module initialization is discouraged."