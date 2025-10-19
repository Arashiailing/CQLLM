/**
 * @name Use of the 'global' statement.
 * @description Identifies global variables declared outside module scope.
 *              This practice violates encapsulation, making code harder to
 *              maintain and debug due to unintended state changes.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables declared in non-module scopes
from Global nonModuleGlobalVar, Scope varScope
where 
  // Extract variable's scope and verify it's not module-level
  varScope = nonModuleGlobalVar.getScope() and
  not varScope instanceof Module
select 
  nonModuleGlobalVar, 
  "Updating global variables except at module initialization is discouraged."