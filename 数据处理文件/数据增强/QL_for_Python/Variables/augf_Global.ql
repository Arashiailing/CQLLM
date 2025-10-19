/**
 * @name Use of the 'global' statement.
 * @description Use of the 'global' statement may indicate poor modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query identifies global variable declarations that occur outside module scope.
// Using global variables in non-module contexts can reduce code maintainability
// by introducing hidden dependencies and making state changes harder to track.
from Global globalVar
// Filter condition: exclude global variables declared at module level, as these
// are typically used for module initialization and are considered acceptable.
where exists(Scope scope | scope = globalVar.getScope() | not scope instanceof Module)
// Query result: select matching global variables with an explanatory warning message
select globalVar, "Updating global variables except at module initialization is discouraged."