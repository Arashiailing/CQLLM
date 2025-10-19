/**
 * @name Detection of non-module global variable usage.
 * @description This query identifies occurrences of the 'global' keyword used outside module scope.
 *              Such usage can lead to code that is hard to maintain and understand, as it may
 *              cause unexpected behavior and make the code flow less predictable.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find global variable declarations that exist outside of module scope
from Global nonModuleGlobalVar
where not nonModuleGlobalVar.getScope() instanceof Module
// Report each non-module global variable usage with a warning message
select nonModuleGlobalVar, "Modifying global variables outside of module initialization is considered a bad practice."