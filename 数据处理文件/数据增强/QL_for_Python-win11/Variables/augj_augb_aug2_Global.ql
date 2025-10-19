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

// This query detects global variable declarations that violate modularity principles
// Global variables should only be used at module level for proper encapsulation
from Global globalVarDecl

// Check if the global declaration is in an inappropriate scope
// Module-level declarations are acceptable as they represent proper initialization
where not globalVarDecl.getScope() instanceof Module

// Report global statements that could lead to poor code maintainability
// Such practices make it harder to reason about data flow and state changes
select globalVarDecl, "Modifying global variables outside of module initialization is not recommended."