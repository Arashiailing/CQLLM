/**
 * @name Usage of 'global' keyword in Python code.
 * @description Identifies instances where 'global' statements are used, potentially indicating a design that lacks proper modularity.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Find all occurrences of global variable declarations throughout the codebase
from Global globalDeclaration
// Filter out global declarations that are outside module-level scope
// Module initialization is the appropriate context for global variable usage
where not globalDeclaration.getScope() instanceof Module
// Flag global statements that could compromise modularity best practices
select globalDeclaration, "Modifying global variables outside of module initialization is not recommended."