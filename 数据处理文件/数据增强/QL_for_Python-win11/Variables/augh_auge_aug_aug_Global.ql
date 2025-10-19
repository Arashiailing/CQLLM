/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables accessed outside module scope.
 *              This practice violates encapsulation principles, leading to
 *              maintenance challenges and debugging difficulties.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables declared in non-module contexts
from Global nonModuleGlobal
// Verify the variable's scope is not module-level
where exists(Scope enclosingScope | 
    enclosingScope = nonModuleGlobal.getScope() | 
    not enclosingScope instanceof Module
)
// Report the global variable instance with warning message
select nonModuleGlobal, "Updating global variables except at module initialization is discouraged."