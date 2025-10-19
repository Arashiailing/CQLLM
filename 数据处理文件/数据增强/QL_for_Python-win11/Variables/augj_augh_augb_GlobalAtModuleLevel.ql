/**
 * @name Use of 'global' at module level
 * @description Detects redundant 'global' statements at module scope where they have no effect
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis library for code structure parsing
import python

// Identify redundant global declarations at module scope
// These declarations are unnecessary as module-level variables are inherently global
from Global redundantGlobalDeclaration, Module scope
where 
    // Check if the global declaration is located within module scope
    // Using 'global' at module level is redundant since variables in this scope are global by default
    scope = redundantGlobalDeclaration.getScope()
select 
    redundantGlobalDeclaration, 
    // Generate warning message highlighting the redundant global declaration
    "Declaring '" + redundantGlobalDeclaration.getAName() + "' as global at module-level is redundant."