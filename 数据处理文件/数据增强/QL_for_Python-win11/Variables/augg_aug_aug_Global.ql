/**
 * @name Use of the 'global' statement.
 * @description Detects global variables utilized outside the module scope.
 *              This practice can result in code that is challenging to maintain and debug,
 *              as it breaches the encapsulation principle.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find global variables that are defined outside of module scope
from Global globalVarOutsideModule
// Ensure the global variable's scope is not at the module level
where not (globalVarOutsideModule.getScope() instanceof Module)
// Output the global variable instance with a cautionary message
select globalVarOutsideModule, "Updating global variables except at module initialization is discouraged."