/**
 * @name Non-module global variable usage detection.
 * @description This query identifies instances where the 'global' keyword is used outside module scope.
 *              Such usage can lead to code that is difficult to maintain and understand.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Source: identify all global variable declarations
from Global globalVarOutsideModule
// Condition: ensure the global variable is declared outside module scope
where 
  // Check that the global variable's scope is not a module
  not globalVarOutsideModule.getScope() instanceof Module
// Output: the global variable and a descriptive warning message
select globalVarOutsideModule, "Modifying global variables outside of module initialization is considered a bad practice."