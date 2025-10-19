/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables accessed outside module scope.
 *              This pattern violates encapsulation and can lead to maintenance
 *              challenges and debugging complexities.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables declared in contexts other than module scope
from Global nonModuleGlobalVar
// Ensure the variable's scope is not at the module level
where exists(Scope variableScope | variableScope = nonModuleGlobalVar.getScope() | not variableScope instanceof Module)
// Report the global variable instance with an appropriate warning message
select nonModuleGlobalVar, "Updating global variables except at module initialization is discouraged."