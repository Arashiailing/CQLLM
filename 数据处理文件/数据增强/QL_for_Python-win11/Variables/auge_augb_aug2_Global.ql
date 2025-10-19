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

// Identify all global variable declarations in the code
from Global globalStmt, Scope declScope
where globalStmt.getScope() = declScope and not declScope instanceof Module
// Highlight global statements that violate modularity principles
select globalStmt, "Modifying global variables outside of module initialization is not recommended."