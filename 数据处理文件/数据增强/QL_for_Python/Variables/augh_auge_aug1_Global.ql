/**
 * @name Use of the 'global' statement.
 * @description Identifies 'global' statements used outside module scope, which may indicate poor code modularity and potential maintenance issues.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query detects 'global' statements that are declared in non-module scopes
// Such usage can lead to code that is difficult to understand and maintain
from Global nonModuleGlobalStmt
// Filter out global statements that are properly placed at module level
// Only report globals defined within functions, classes, or other nested scopes
where not nonModuleGlobalStmt.getScope() instanceof Module
// Report each non-module global statement with a contextual warning message
select nonModuleGlobalStmt, "Updating global variables except at module initialization is discouraged."