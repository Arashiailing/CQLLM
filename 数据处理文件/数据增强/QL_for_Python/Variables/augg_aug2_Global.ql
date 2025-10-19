/**
 * @name Detection of 'global' keyword usage.
 * @description Identifies instances where 'global' statements are used, potentially indicating suboptimal modular design patterns.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query identifies 'global' statements that are not at module level
from Global globalVarDeclaration
// Only consider global declarations outside module scope
where not globalVarDeclaration.getScope() instanceof Module
// Report these as potentially harmful to modularity
select globalVarDeclaration, "Modifying global variables outside of module initialization is not recommended."