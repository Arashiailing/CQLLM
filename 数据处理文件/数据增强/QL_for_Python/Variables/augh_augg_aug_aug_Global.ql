/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables accessed outside module initialization scope.
 *              This practice violates encapsulation principles and may lead to 
 *              maintenance challenges and debugging difficulties.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variable declarations occurring outside module scope
from Global nonModuleGlobalVar
// Verify the variable's scope is not module-level initialization
where not (nonModuleGlobalVar.getScope() instanceof Module)
// Report instances with contextual warning message
select nonModuleGlobalVar, "Modifying global variables outside module initialization is discouraged."