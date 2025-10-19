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

// Identify all 'global' statements in the codebase
from Global globalVarDecl
// Filter for global declarations that are outside module-level scope
// Module-level global declarations are acceptable as they represent proper module initialization
where not globalVarDecl.getScope() instanceof Module
// Flag these global statements as potentially compromising modularity best practices
select globalVarDecl, "Modifying global variables outside of module initialization is not recommended."