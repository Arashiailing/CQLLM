/**
 * @name Redundant module-level global declarations
 * @description Identifies unnecessary 'global' statements at module scope in Python code
 * @kind problem
 * @tags maintainability
 *       useless-code
 * @problem.severity warning
 * @sub-severity low
 * @precision very-high
 * @id py/redundant-global-declaration
 */

// Import Python analysis framework
import python

// Identify global declarations with module-level scope
from Global redundantGlobal
where 
    // Verify the declaration occurs at module scope
    redundantGlobal.getScope() instanceof Module
select 
    redundantGlobal, 
    // Generate warning message for redundant global declaration
    "Redundant global declaration of '" + redundantGlobal.getAName() + "' at module level."