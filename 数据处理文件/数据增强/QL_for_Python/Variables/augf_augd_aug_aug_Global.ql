/**
 * @name Non-module global variable usage
 * @description Identifies global variables accessed or modified within non-module scopes.
 *              This pattern violates encapsulation principles, making code maintenance and debugging
 *              more difficult by allowing unrestricted variable modifications across the codebase.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

from Global nonModuleGlobal
where 
  // Exclude global variables declared at module initialization level
  not (nonModuleGlobal.getScope() instanceof Module)
select nonModuleGlobal, "Updating global variables except at module initialization is discouraged."