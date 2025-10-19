/**
 * @name Identification of 'global' statement usage.
 * @description Detects occurrences of 'global' declarations which may signify poor modular design practices.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query identifies 'global' statements that are not at module level
from Global globalStmt
// Filter for global declarations outside module scope
where not globalStmt.getScope() instanceof Module
// Report these instances as potentially harmful to modularity
select globalStmt, "Modifying global variables outside of module initialization is not recommended."