/**
 * @name Use of the 'global' statement.
 * @description Detects 'global' statements used within nested scopes (functions, classes, etc.) rather than at module level. This practice can make code harder to understand, test, and maintain due to implicit dependencies and hidden state changes.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// This query identifies global variable declarations that appear inside nested scopes
// rather than at the module level, which can create maintenance challenges
// and make code behavior less predictable
from Global globalStmtInNestedScope
// Only consider global statements that are not at module level
// These are typically found inside functions, methods, classes, or other nested constructs
where not globalStmtInNestedScope.getScope() instanceof Module
// Generate an alert for each global statement in nested scope
// with a message discouraging this practice
select globalStmtInNestedScope, "Updating global variables except at module initialization is discouraged."