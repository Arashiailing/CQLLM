/**
 * @name Usage of 'global' keyword in Python code.
 * @description Identifies instances where 'global' statements are used outside module scope,
 *              which may indicate a design that lacks proper modularity and encapsulation.
 * @kind problem
 * @problem.severity recommendation
 * @sub-severity low
 * @deprecated
 * @precision very-high
 * @id py/use-of-global
 */

import python

// Identify global variable declarations that are not at module level
from Global globalDeclaration, Scope declarationScope
where 
    // Associate the global statement with its containing scope
    globalDeclaration.getScope() = declarationScope
    // Filter out module-level scopes as they are acceptable
    and not declarationScope instanceof Module
// Highlight global statements that violate modularity principles
select globalDeclaration, "Modifying global variables outside of module initialization is not recommended."