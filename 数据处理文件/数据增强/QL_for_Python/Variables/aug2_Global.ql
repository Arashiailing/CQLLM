/**
 * @name Use of the 'global' statement.
 * @description Detects usage of 'global' statements which may indicate poor modularity design.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify all global variable declarations in the codebase
from Global globalStmt
// Filter for global statements that are not at module level scope
// Global variables should ideally only be used at module initialization
where not globalStmt.getScope() instanceof Module
// Report global statements that violate modularity principles
select globalStmt, "Updating global variables except at module initialization is discouraged."