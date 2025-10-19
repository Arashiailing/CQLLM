/**
 * @name Use of the 'global' statement.
 * @description Detects global variables accessed/modified outside module scope.
 *              This practice violates encapsulation, causes unintended side effects,
 *              and increases maintenance/debugging complexity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variables used in non-module contexts
from Global globalVar, Scope variableScope
where 
  // Ensure variable's scope is not module-level
  variableScope = globalVar.getScope() and
  not variableScope instanceof Module
select 
  globalVar, 
  "Updating global variables except at module initialization is discouraged."