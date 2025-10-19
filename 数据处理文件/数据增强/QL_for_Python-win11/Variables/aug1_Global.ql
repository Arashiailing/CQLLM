/**
 * @name Use of the 'global' statement.
 * @description Detects usage of 'global' statements outside module scope, which may indicate poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify all global variable declarations that are not at module level
from Global globalVariable
// Exclude global variables defined at module scope (module initialization)
where not globalVariable.getScope() instanceof Module
// Report findings with contextual warning message
select globalVariable, "Updating global variables except at module initialization is discouraged."