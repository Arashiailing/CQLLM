/**
 * @name Non-module global variable usage detection.
 * @description This query finds occurrences of the 'global' keyword when used outside module scope,
 *              potentially resulting in code that's hard to maintain and comprehend.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Source: all global variable declarations
from Global nonModuleGlobalVar
// Condition: global variable must be outside module scope
where 
  // Verify the global variable is not declared within module scope
  not nonModuleGlobalVar.getScope() instanceof Module
// Output: the global variable and a warning message
select nonModuleGlobalVar, "Modifying global variables outside of module initialization is considered a bad practice."