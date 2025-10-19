/**
 * @name Use of the 'global' statement.
 * @description Detects global variables utilized beyond module scope.
 *              This practice can result in code that is challenging to maintain and debug,
 *              as it breaks the encapsulation principle.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables declared outside of module scope
from Global nonModuleGlobal
// Ensure the global variable's scope is not at module level
where not (nonModuleGlobal.getScope() instanceof Module)
// Return the global variable instance with a warning message
select nonModuleGlobal, "Updating global variables except at module initialization is discouraged."