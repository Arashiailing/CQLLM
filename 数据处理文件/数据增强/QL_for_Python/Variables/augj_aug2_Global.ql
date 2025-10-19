/**
 * @name Non-module level global variable usage.
 * @description Identifies 'global' statements used outside module scope, which can lead to poor code modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variable declarations that are not at module level
from Global nonModuleGlobalDecl
where 
  // Filter for global statements that are not at module level scope
  not nonModuleGlobalDecl.getScope() instanceof Module
select 
  // Report global statements that violate modularity principles
  nonModuleGlobalDecl, "Updating global variables except at module initialization is discouraged."