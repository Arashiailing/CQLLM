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

// Find all global variable declarations in the codebase
from Global globalDeclaration, Scope enclosingScope

// Check if the global statement is defined within a non-module scope
where globalDeclaration.getScope() = enclosingScope
  and not enclosingScope instanceof Module

// Report global statements that violate modularity design principles
select globalDeclaration, "Modifying global variables outside of module initialization is not recommended."