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

// Identify all global variable declarations in the codebase
from Global globalStatement
// Filter for global statements that are not at module level
// Global variables should ideally only be used at module initialization
where not globalStatement.getScope() instanceof Module
// Report findings with contextual warning message
select globalStatement, "Updating global variables except at module initialization is discouraged."