/**
 * @name Use of the 'global' statement.
 * @description Detects usage of global statements outside module scope, which may indicate poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Locate all global variable declarations that violate modularity principles
// Global statements should be restricted to module initialization scope only
from Global globalVarDecl
where not globalVarDecl.getScope() instanceof Module
// Generate alert for global variable usage outside module level
select globalVarDecl, "Updating global variables except at module initialization is discouraged."