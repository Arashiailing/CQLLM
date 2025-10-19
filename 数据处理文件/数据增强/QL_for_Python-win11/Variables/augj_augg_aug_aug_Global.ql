/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables referenced outside the module scope.
 *              This practice can lead to code that is difficult to maintain and debug,
 *              as it violates the encapsulation principle.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables that are used outside of module scope
from Global nonModuleGlobalVar
// Verify that the global variable's scope is not at the module level
where not (nonModuleGlobalVar.getScope() instanceof Module)
// Output the global variable instance with a warning message
select nonModuleGlobalVar, "Modifying global variables outside of module initialization is not recommended."