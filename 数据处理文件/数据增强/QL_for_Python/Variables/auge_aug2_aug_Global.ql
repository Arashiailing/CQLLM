/**
 * @name Detection of non-module global variable usage
 * @description Identifies global keyword usage outside module scope, 
 *              which can lead to maintainability issues and code confusion.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variable declarations outside module scope
from Global nonModuleGlobalVar
// Filter for globals not declared at module level
where not nonModuleGlobalVar.getScope() instanceof Module
// Report the problematic global declaration
select nonModuleGlobalVar, "Modifying global variables outside of module initialization is considered a bad practice."