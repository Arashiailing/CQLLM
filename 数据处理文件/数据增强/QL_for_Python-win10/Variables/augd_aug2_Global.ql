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

// This query identifies global variable declarations that violate modularity principles
// Global statements should only appear at module scope for proper initialization
from Global globalVariableDeclaration
where 
    // Filter out global declarations that are properly placed at module level
    // We want to find those that are inappropriately used in other scopes
    not globalVariableDeclaration.getScope() instanceof Module
// Report problematic global statements with appropriate guidance
select globalVariableDeclaration, "Updating global variables except at module initialization is discouraged."