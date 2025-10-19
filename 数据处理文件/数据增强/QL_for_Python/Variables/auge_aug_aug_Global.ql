/**
 * @name Use of the 'global' statement.
 * @description Detects global variables accessed outside module scope.
 *              This practice can create maintenance challenges and debugging difficulties,
 *              as it breaks encapsulation principles.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find global variables declared in non-module contexts
from Global globalVarOutsideModule
// Verify the variable's scope is not at module level
where exists(Scope varScope | varScope = globalVarOutsideModule.getScope() | not varScope instanceof Module)
// Output the global variable instance with appropriate warning
select globalVarOutsideModule, "Updating global variables except at module initialization is discouraged."